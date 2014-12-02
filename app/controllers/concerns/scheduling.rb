# Module for generating schedule
# Use of concerns: http://richonrails.com/articles/rails-4-code-concerns-in-active-record-models

require 'priority_queue'

module Scheduling
  extend ActiveSupport::Concern
 
  def testing
    @test = 3
  end

  class ProgTimer
    attr_accessor :whenToPlay, :prog

    def initialize(prog)
      @prog = prog;
      @whenToPlay = prog.period;
    end

    def setNextPlay
      @whenToPlay = @whenToPlay + @prog.period
    end

    def <=>(otherTimer)
      timeDiff = @whenToPlay - otherTimer.whenToPlay
      eps = 0.00001
      return (timeDiff.abs < eps) ? (rand(2) * 2 - 1) : (timeDiff <=> 0)
    end
  end

  class SummaryItem
    attr_accessor :programme_id,
                  :visualisation_id, :priority, 
                  :screens, :vis_playout_time
    
    def initialize(prog_id, vis_id, priority, screens, vis_playout_time)
      @programme_id = prog_id
      @visualisation_id = vis_id
      @priority = priority
      @screens = screens
      @vis_playout_time = vis_playout_time
    end
  end

  def get_a_default_programme(timeslot)
    vis = Visualisation.where(isDefault:true).sample
    prog = Programme.new({:screens => Const.MIN_NO_SCREENS,
                          :priority => Const.MIN_PRIORITY
                         })
    vis.programmes << prog
    timeslot.programmes << prog

    return prog
  end

  def clean_old_sessions(start_time, end_time)
    oldSessions = PlayoutSession.where(start_time: start_time...end_time)
    oldSessions.destroy_all
  end

  def generate_schedule(timeslot, rows = Const.DEFAULT_ROW, 
                        cols = Const.DEFAULT_COLUMN)
    start_time = timeslot.start_time.beginning_of_minute() 
    end_time = timeslot.end_time.beginning_of_minute()
    progs = timeslot.programmes

    clean_old_sessions(start_time, end_time)

    queue = initQueue(progs, rows, cols)
    nextFreeTimeslot = Array.new(rows){Array.new(cols, start_time)}

    selectedProgTimes = Array.new
    multi_row = false

    curr_time = start_time
    while curr_time < end_time
      allRows = (0...rows).to_a.shuffle

      # Iterate through randomised rows
      allRows.each do |curr_row|
        if (!multi_row)
          curr_col = 0
          while curr_col < cols
            if (nextFreeTimeslot[curr_row][curr_col] <= curr_time) then
              start_col = curr_col

              # find number of continuous free (not occupied by vis) screens
              block_size = Const.MIN_NO_SCREENS
              while (block_size < cols - curr_col)
                if (nextFreeTimeslot[curr_row][curr_col + block_size] > curr_time) then
                  break
                end
                block_size += 1
              end
              curr_col += block_size
              
              # find feasible programme(s)
              selectedProgrammes = Array.new
              filled_blocks = 0
              while (!queue.empty? && filled_blocks < block_size)

                # If programme in head of queue is too big, block the whole queue
                if (queue.min.first.prog.screens > block_size - filled_blocks ||
                    selectedProgTimes.include?(queue.min.first)) then
                  break
                end

                # Feasible programme at head of queue, remove from queue
                #  for scheduling and prepare for requeue
                head = queue.delete_min.first
                if (head.prog.duration <= 2 * (end_time - curr_time))
                  selectedProgrammes << head.prog
                  filled_blocks += head.prog.screens
                  requeue([head], queue)
                  selectedProgTimes << head
                end
                # else programme cannot be selected to play at a later time
                #  - we do not requeue
              end

              # Fill empty space with default visualisation
              try_fill = 0
              while (filled_blocks < block_size && try_fill < Const.MAX_TRY_FILL)
                defaultProg = get_a_default_programme(timeslot)
                try_fill += 1
                if (!defaultProg.visualisation_id.nil? &&
                    filled_blocks + defaultProg.screens <= block_size)
                  selectedProgrammes << defaultProg
                  filled_blocks += defaultProg.screens
                  try_fill = 0
                end
              end

              # Sort selected programmes in ascending duration
              selectedProgrammes.sort!
              
              # Decide how to align programmes
              if ((start_col == Const.FIRST_SCREEN && block_size < cols) ||
                  (start_col > Const.FIRST_SCREEN && curr_col < cols &&
                   nextFreeTimeslot[curr_row][start_col - 1] < 
                     nextFreeTimeslot[curr_row][curr_col]))
                schedule_in_ascending_order = false
              elsif ((curr_col == cols && block_size < cols) ||
                     (start_col > Const.FIRST_SCREEN && curr_col < cols &&
                      nextFreeTimeslot[curr_row][start_col - 1] > 
                      nextFreeTimeslot[curr_row][curr_col]))
                schedule_in_ascending_order = true
              else
                # No specific preference
                ascending_duration = (rand(2) == 0)
              end

              if (schedule_in_ascending_order) 
                # Push programmes to far right
                start_col += block_size - filled_blocks;
                while (!selectedProgrammes.empty?)
                  prog = selectedProgrammes.shift
                  prog_end_time = [(curr_time + prog.duration), end_time].min
                  createSession(prog, cols * curr_row + start_col,
                                curr_time, prog_end_time)
                  for i in 0...prog.screens
                    nextFreeTimeslot[curr_row][start_col + i] = prog_end_time
                  end
                  start_col += prog.screens
                end
              else
                # Push programmes to far left
                start_col += filled_blocks
                while (!selectedProgrammes.empty?)
                  prog = selectedProgrammes.shift
                  start_col -= prog.screens
                  prog_end_time = [(curr_time + prog.duration), end_time].min
                  createSession(prog, cols * curr_row + start_col,
                                curr_time, prog_end_time)
                  for i in 0...prog.screens
                    nextFreeTimeslot[curr_row][start_col + i] = prog_end_time
                  end
                end
              end    
            end
            
            # Advance to next screen
            curr_col += 1
          end


        end
        
        if (multi_row)
          prog_rows = queue.min.first.prog.screens/cols

          if (curr_row + prog_rows <= rows)
            if (toggleMultiRowMode(prog_rows, cols, curr_row, curr_time,
                                   nextFreeTimeslot))
              next
            end
            head = queue.delete_min.first
            if (head.prog.duration <= 2 * (end_time - curr_time))
              #selectedProgrammes << head.prog
              selectedProgTimes << head
              requeue([head], queue)
              #  -- required?
              

              prog_end_time = [(curr_time + prog.duration), end_time].min
              createSession(prog, cols * curr_row, curr_time, prog_end_time)
              
              (0...prog_rows).each do |r|
                (0...cols).each do |curr_col|
                  nextFreeTimeslot[curr_row + r][curr_col] = prog_end_time
                end
              end

              multi_row = false;
            end
            # else programme cannot be selected to play at a later time
            #  - we do not requeue
          end

        end
      end

      # Clean up selected programmes/ProgTime queues
      selectedProgTimes.clear   

      # Advance to next unit time
      curr_time += Const.SECONDS_IN_UNIT_TIME
    end

    return queue
  end

  def toggleMultiRowMode(prog_rows, total_cols, curr_row, curr_time,
                         nextFreeTimeslot)
    (0...prog_rows).each do |row|
      (0...total_cols).each do |curr_col|
        if (nextFreeTimeslot[curr_row + row][curr_col] > curr_time)
          return true
        end
      end
    end

    return false
  end

  def initQueue(progs, rows, cols)
    queue = PriorityQueue.new
    progs.each do |prog|
      if (prog.screens <= cols)
        progTimer = ProgTimer.new(prog)
      elsif (prog.screens <= rows * cols)
        progTimer = ProgTimer.new(
          getProgWithModifiedScreens(prog, prog.screens - prog.screens.modulo(cols)))
      else
        progTimer = getProgWithModifiedScreens(prog, rows * cols)
      end    
      queue.push progTimer, progTimer
    end

    return queue
  end

  def getProgWithModifiedScreens(prog, newScreens)
    newProg = Programme.new({:screens => newScreens,
                             :priority => prog.priority,
                             :timeslot_id => prog.timeslot_id,
                             :visualisation_id => prog.visualisation_id})
    return newProg
  end

  def requeue(progTimers, queue)
    progTimers.each do |progTimer|
      progTimer.setNextPlay
      queue.push progTimer, progTimer
    end
  end

  def createSession(prog, start_col, start_time, end_time)
    s = PlayoutSession.create({:start_time => start_time,
                               :end_time => end_time,
                               :start_screen => start_col,
                               :end_screen => start_col + prog.screens - 1})
    prog.visualisation.playout_sessions << s
    prog.timeslot.playout_sessions << s
  end

  def getSummary(timeslot)
    start_time = timeslot.start_time
    end_time = timeslot.end_time

    playouts = PlayoutSession.where(start_time: start_time...end_time)

    vis_playtimes = {}

    time_elapsed = 0
    while start_time + time_elapsed < end_time
      playout_vis =
        playouts.where("start_time <= :now AND :now < end_time",
                       {now: (start_time + time_elapsed)}).
          select(:visualisation_id).distinct

      playout_vis.each do |vis|
        if (!vis_playtimes.has_key?(vis.visualisation_id)) 
          vis_playtimes[vis.visualisation_id] = 0
        end
        vis_playtimes[vis.visualisation_id] += Const.SECONDS_IN_UNIT_TIME
      end

      time_elapsed += Const.SECONDS_IN_UNIT_TIME
    end

    summary = []
    
    timeslot.programmes.each do |prog|
      summary << SummaryItem.new(prog.id, prog.visualisation_id,
                                 prog.priority, prog.screens,
                                 vis_playtimes.has_key?(prog.visualisation_id)? 
                                   vis_playtimes[prog.visualisation_id] : 0)
    end

    return summary
  end

end
