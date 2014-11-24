require 'rails_helper'
require 'priority_queue'
include Scheduling
include Const

RSpec.describe Scheduling, :type => :concern do

  describe '.get_a_default_programme' do
    Visualisation.create([
      {:name => "Milan"}, 
      {:name => "Green"},
      {:name => "Pink"}, 
      {:name => "Power", :isDefault => true}, 
    ])

    prog = get_a_default_programme
    vis = Visualisation.find(prog.visualisation_id)

    it 'should return a programme containing default visualisation' do
      expect(vis.isDefault).to be true
    end

    it 'should return a programme with lowest priority' do
      expect(prog.priority).to eq(Const.MIN_PRIORITY)
    end

    it 'should return a programme with lowest no. of screen(s)' do
      expect(prog.screens).to eq(Const.MIN_NO_SCREENS)
    end
  end

  emptyProgs = Programme.create([])
  underPopulatedProgs = Programme.create([{:screens => 1, :priority => 4}])
  wellPopulatedProgs = Programme.create([{:screens => 1, :priority => 4},
                                         {:screens => 4, :priority => 3}, 
                                         {:screens => 3, :priority => 2},
                                         {:screens => 2, :priority => 1}])

  describe '.get_total_screen_load' do
    it 'should return the sum of all programme\'s screens' do
      expect(get_total_screen_load(emptyProgs)).to be 0
      expect(get_total_screen_load(underPopulatedProgs)).to be 1
      expect(get_total_screen_load(wellPopulatedProgs)).to be 10
    end
  end

  

  describe '.clean_old_sessions' do
    it 'should clean all the existing session within the timeslot' do
      for i in 0..2
      PlayoutSession.create(
        {:start_time => DateTime.new(2014, 9, 1, 12, i, 0).utc,
         :end_time => DateTime.new(2014, 9, 1, 12, i+1, 0).utc})
      end

      start_time = DateTime.new(2014, 9, 1, 12, 0, 0).utc
      end_time = DateTime.new(2014, 9, 1, 13, 0, 0).utc

      clean_old_sessions(start_time, end_time)

      sessions = PlayoutSession.where(start_time: start_time...end_time)
      expect(sessions.length).to be 0
    end
  end

  describe '.generate_schedule' do
    context 'schedule playout with time proportional to priority' do
      def getTotalPlaytime (playouts)
        playtimes = {}

        start_time = playouts.minimum("start_time")
        end_time = playouts.maximum("end_time")

        time_elapsed = 0
        while start_time + time_elapsed < end_time
          playout_vis =
            playouts.where("start_time <= :now AND :now < end_time",
                           {now: (start_time + time_elapsed)}).
              select(:visualisation_id).distinct

          playout_vis.each do |vis|
            if (!playtimes.has_key?(vis.visualisation_id)) 
              playtimes[vis.visualisation_id] = 0
            end
            playtimes[vis.visualisation_id] += Const.SECONDS_IN_UNIT_TIME
          end

          time_elapsed += Const.SECONDS_IN_UNIT_TIME
        end
        
        return playtimes
      end

      it 'for one programme (overriding case)' do
        pending 'write test'
      end
      it 'for more than one programme: example 1' do
        vis1 = Visualisation.create({:name => "Milan"})
        vis2 = Visualisation.create({:name => "Green", :min_playtime => 120})
        vis3 = Visualisation.create({:name => "Pink"})
        vis4 = Visualisation.create({:name => "Power"})
        vis5 = Visualisation.create({:name => "Test"})

        prog1 = Programme.create({:screens => 2, :priority => 1})
        vis1.programmes << prog1
        prog2 = Programme.create({:screens => 1, :priority => 5})
        prog2.visualisation = vis2
        prog3 = Programme.create({:screens => 1, :priority => 10})
        prog3.visualisation = vis3
       

        start_time = DateTime.new(2014, 9, 2, 12, 0, 0).utc
        end_time = DateTime.new(2014, 9, 2, 13, 0, 0).utc

        timeslot = Timeslot.create({:start_time => start_time,
                                    :end_time => end_time})
        timeslot.programmes << [prog1, prog2, prog3]
        generate_schedule(timeslot)

        playouts = PlayoutSession.where(start_time: start_time...end_time)

        playtimes = getTotalPlaytime(playouts)
        expect(playtimes).to be 1
      end
    end  
    
    context 'should work for 2x2 screen configuration:' do
      it 'no 1x2 vis should be on screens in two seperate rows' do
        pending 'write test'
      end
    end 
  end

  describe '.initQueue' do
    it 'initialise queue with increasing time for next playout' do
      vis1 = Visualisation.create({:name => "Milan"})
      vis2 = Visualisation.create({:name => "Green", :min_playtime => 120})
      vis3 = Visualisation.create({:name => "Pink"})

      prog1 = Programme.create({:screens => 2, :priority => 1})
      prog1.visualisation = vis1
      prog2 = Programme.create({:screens => 1, :priority => 5})
      prog2.visualisation = vis2
      prog3 = Programme.create({:screens => 1, :priority => 4})
      prog3.visualisation = vis3

      queue = initQueue([prog1, prog2, prog3])
      expect(queue.min.first.prog).to be prog3
      expect(queue.delete_min.first.prog).to be prog3
      expect(queue.delete_min.first.prog).to be prog2
      expect(queue.delete_min.first.prog).to be prog1
    end
  end

end

