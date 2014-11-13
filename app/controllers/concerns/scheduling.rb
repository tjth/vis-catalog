# Module for generating schedule
# Use of concerns: http://richonrails.com/articles/rails-4-code-concerns-in-active-record-models

module Scheduling
  extend ActiveSupport::Concern
 
  def testing
    @test = 3
  end

  class PlayoutModel
    def initialize(time, queue)
      @time = time
      @schedule_items = [nil] * Const.NO_OF_SCREENS
      @programmes = [nil] * Const.NO_OF_SCREENS
      @queue = queue
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

  def preprocess_and_build_queue(programmes)
    queue = programmes.sort_by{|prog| prog.priority}.reverse
    initScrLoad = get_total_screen_load(queue)
    if (initScrLoad < Const.NO_OF_SCREENS)
      for i in 1..(Const.NO_OF_SCREENS - initScrLoad)
        queue = queue + [get_a_default_programme]
      end
    end
    return queue 
  end

  def clean_old_sessions(start_time, end_time)
    oldSessions = PlayoutSession.where(start_time: start_time...end_time)
    oldSessions.destroy_all
  end

  def generate_schedule(timeslot)
    start_time = timeslot.start_time
    end_time = timeslot.end_time
    progs = timeslot.programmes

    queue = preprocess_and_build_queue(progs)
    playSys = PlayoutModel.new(start_time, queue)

    clean_old_sessions(start_time, end_time)

    if (get_total_screen_load(queue) == Const.NO_OF_SCREENS)
      if (queue.length == Const.OVERRIDING_QUEUE_LENGTH)
        session = 
          PlayoutSession.create({:start_time => start_time,
                                 :end_time => end_time,
                                 :start_screen => Const.MIN_SCREEN_NUMBER,
                                 :end_screen => Const.NO_OF_SCREENS,
                                })
        vis = Visualisation.find(queue.first.visualisation_id)
        vis.playout_sessions << session
        return
      end
    end

    return []
  end
end
