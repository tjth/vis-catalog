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

  def get_a_default_programme
    vis = Visualisation.where(isDefault:true).sample
    prog = Programme.new({:screens => Const.MIN_NO_SCREENS,
                          :priority => Const.MIN_PRIORITY
                         })

    vis.programmes << prog
    return prog
  end

  def get_total_screen_load(programmes)
    scrLoad = 0
    programmes.each do |programme|
      scrLoad = scrLoad + programme.screens
    end
    return scrLoad
  end

  def clean_old_sessions(start_time, end_time)
    oldSessions = PlayoutSession.where(start_time: start_time...end_time)
    oldSessions.destroy_all
  end

  def generate_schedule(timeslot)
    start_time = timeslot.start_time - 
                 timeslot.start_time.to_i.modulo(Const.SECONDS_IN_UNIT_TIME)
    end_time = timeslot.end_time - 
               timeslot.end_time.to_i.modulo(Const.SECONDS_IN_UNIT_TIME)
    progs = timeslot.programmes

    clean_old_sessions(start_time, end_time)

    queue = initQueue(progs)
    nextFreeTimeslot = Array.new(Const.NO_OF_SCREENS, start_time)

    selectedProgTimes = Array.new
    selectedProgrammes = Array.new

    curr_time = start_time
    while curr_time < end_time
      curr_screen = Const.FIRST_SCREEN

      while curr_screen < Const.NO_OF_SCREENS
        if (nextFreeTimeslot[curr_screen] <= curr_time) then
          start_screen = curr_screen

          # find number of continuous free (not occupied by vis) screens
          block_size = Const.MIN_NO_SCREENS
          while (block_size < Const.NO_OF_SCREENS - curr_screen)
            if (nextFreeTimeslot[curr_screen + block_size] > curr_time) then
              break
            end
            block_size += 1
          end
          curr_screen += block_size
          
          # find feasible programme(s)
          filled_blocks = 0
          while (!queue.empty? && filled_blocks < block_size)

            # If programme in head of queue is too big, block the whole queue
            if (queue.min.first.prog.screens > block_size - filled_blocks) then
              break
            end

            # Feasible programme at head of queue, remove from queue
            #  for scheduling and prepare for requeue
            head = queue.delete_min.first
            if (head.prog.duration <= 2 * (end_time - curr_time))
              selectedProgrammes << head.prog
              filled_blocks += head.prog.screens
              selectedProgTimes << head
              # else programme cannot be selected to play at a later time
              #  - we do not requeue
            end
          end

          # Fill empty space with default visualisation
          # TODO: implement java line 55 - 65

          # Sort selected programmes in ascending duration
          selectedProgrammes.sort!
          
          # Decide how to align programmes
          if (start_screen == Const.FIRST_SCREEN && block_size < Const.NO_OF_SCREENS ||
              start_screen > Const.FIRST_SCREEN && curr_screen < Const.NO_OF_SCREENS &&
                nextFreeTimeslot[start_screen - 1] < nextFreeTimeslot[curr_screen])
            schedule_in_ascending_order = false
          elsif (curr_screen == Const.NO_OF_SCREENS && block_size < Const.NO_OF_SCREENS ||
                 start_screen > Const.FIRST_SCREEN && curr_screen < Const.NO_OF_SCREENS)
            schedule_in_ascending_order = true
          else
            # No specific preference
            ascending_duration = (rand(2) == 0)
          end

          if (schedule_in_ascending_order) 
            # Push programmes to far right
            start_screen += block_size - filled_blocks;
            while (!selectedProgrammes.empty?)
              prog = selectedProgrammes.shift
              prog_end_time = [(curr_time + prog.duration), end_time].min
              createSession(prog, start_screen, curr_time, prog_end_time)
              for i in 0...prog.screens
                nextFreeTimeslot[start_screen + i] = prog_end_time
              end
              start_screen += prog.screens
            end
          else
            # Push programmes to far left
            start_screen += filled_blocks
            while (!selectedProgrammes.empty?)
              prog = selectedProgrammes.shift
              start_screen -= prog.screens
              prog_end_time = [(curr_time + prog.duration), end_time].min
              createSession(prog, start_screen, curr_time, prog_end_time)
              for i in 0...prog.screens
                nextFreeTimeslot[start_screen + i] = prog_end_time
              end
            end
          end
          
          # Clean up selected programmes/ProgTime queues
          selectedProgrammes.clear
          requeue(selectedProgTimes, queue)
          selectedProgTimes.clear     
        end
        
        # Advance to next screen
        curr_screen += 1
      end

      # Advance to next unit time
      curr_time += Const.SECONDS_IN_UNIT_TIME
    end

    return queue
  end

  def initQueue(progs)
    queue = PriorityQueue.new
    progs.each do |prog|
      progTimer = ProgTimer.new(prog)
      queue.push progTimer, progTimer
    end

    return queue
  end

  def requeue(progTimers, queue)
    progTimers.each do |progTimer|
      progTimer.setNextPlay
      queue.push progTimer, progTimer
    end
  end

  def createSession(prog, start_screen, start_time, end_time)
    s = PlayoutSession.create({:start_time => start_time,
                               :end_time => end_time,
                               :start_screen => start_screen,
                               :end_screen => start_screen + prog.screens - 1})
    prog.visualisation.playout_sessions << s
  end

end
