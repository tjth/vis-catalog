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
    prog = Programme.new({:screens => Const.MIN_SCREENS,
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
end
