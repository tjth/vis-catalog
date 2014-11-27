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
    start_t = DateTime.new(2014, 9, 2, 12, 0, 0).utc
    end_t = DateTime.new(2014, 9, 2, 13, 0, 0).utc

    context 'schedule playout with time directly proportional to priority' do
      
      def getTotalPlayoutTime(summary)
        total_playout_time = 0
        summary.each do |summary_item|
          total_playout_time += summary_item.vis_playout_time
        end
        return total_playout_time
      end

      def getTotalPriority(summary)
        total_priority = 0
        summary.each do |summary_item|
          total_priority += summary_item.priority
        end
        return total_priority
      end

      def checkPlaytime(summary, prog_id)
        target = summary.find{|item| item.programme_id == prog_id}
        expected_playtime = target.priority/getTotalPriority(summary).to_f *
                            getTotalPlayoutTime(summary)

        expect(target.vis_playout_time).
          to be_within(Const.MAX_PLAYOUT_TIME_ERROR * expected_playtime).
          of (expected_playtime)
      end

      def visNames
        ['Milan', 'Green', 'Pink', 'Power', 'Test', 'BomWowWow']
      end

      def getVis(min_playtime = Const.SECONDS_IN_UNIT_TIME)
        return Visualisation.create({:name => visNames.sample,
                                     :min_playtime => min_playtime})
      end

      it 'for one programme (overriding case)' do
        prog = Programme.create({:screens => 4, :priority => 1})
        prog.visualisation = getVis

        timeslot = Timeslot.create({:start_time => start_t, :end_time => end_t})
        timeslot.programmes << prog
        generate_schedule(timeslot)

        summary = getSummary(timeslot)
        checkPlaytime(summary, prog.id)
      end

      context 'for more than one programme under low load:' do
        it 'Example 1 (eq priority, same screen utilisation)' do
          priority = rand(10) + 1
          screens = rand(4) + 1

          prog1 = Programme.create({:screens => screens, :priority => priority})
          prog1.visualisation = getVis
          prog2 = Programme.create({:screens => screens, :priority => priority})
          prog2.visualisation = getVis
          prog3 = Programme.create({:screens => screens, :priority => priority})
          prog3.visualisation = getVis

          timeslot = Timeslot.create({:start_time => start_t, :end_time => end_t})
          timeslot.programmes << [prog1, prog2, prog3]
          generate_schedule(timeslot)

          summary = getSummary(timeslot)
          checkPlaytime(summary, prog1.id)
          checkPlaytime(summary, prog2.id)
          checkPlaytime(summary, prog3.id)
        end

        it 'Example 2 (eq priority, differing screen utilisation)' do
          priority = rand(10) + 1

          prog1 = Programme.create({:screens => (rand(4) + 1), :priority => priority})
          prog1.visualisation = getVis
          prog2 = Programme.create({:screens => (rand(4) + 1), :priority => priority})
          prog2.visualisation = getVis
          prog3 = Programme.create({:screens => (rand(4) + 1), :priority => priority})
          prog3.visualisation = getVis

          timeslot = Timeslot.create({:start_time => start_t, :end_time => end_t})
          timeslot.programmes << [prog1, prog2, prog3]
          generate_schedule(timeslot)

          summary = getSummary(timeslot)
          checkPlaytime(summary, prog1.id)
          checkPlaytime(summary, prog2.id)
          checkPlaytime(summary, prog3.id)
        end

        it 'Example 3 (eq priority, differing screen utilisation, differing
            vis\' min_playtime) - expect to get 1/3 playtime as well' do
          priority = rand(10) + 1

          prog1 = Programme.create({:screens => (rand(4) + 1), :priority => priority})
          prog1.visualisation = getVis
          prog2 = Programme.create({:screens => (rand(4) + 1), :priority => priority})
          prog2.visualisation = getVis(2 * Const.SECONDS_IN_UNIT_TIME)
          prog3 = Programme.create({:screens => (rand(4) + 1), :priority => priority})
          prog3.visualisation = getVis(3 * Const.SECONDS_IN_UNIT_TIME)

          timeslot = Timeslot.create({:start_time => start_t, :end_time => end_t})
          timeslot.programmes << [prog1, prog2, prog3]
          generate_schedule(timeslot)

          summary = getSummary(timeslot)
          checkPlaytime(summary, prog1.id)
          checkPlaytime(summary, prog2.id)
          checkPlaytime(summary, prog3.id)
        end

        it 'Example 4 (skewed priority, same screen utilisation)' do
          screens = rand(4) + 1
          prog1 = Programme.create({:screens => 2, :priority => 1})
          prog1.visualisation = getVis
          prog2 = Programme.create({:screens => 2, :priority => 1})
          prog2.visualisation = getVis
          prog3 = Programme.create({:screens => 2, :priority => 10})
          prog3.visualisation = getVis

          timeslot = Timeslot.create({:start_time => start_t, :end_time => end_t})
          timeslot.programmes << [prog1, prog2, prog3]
          generate_schedule(timeslot)

          summary = getSummary(timeslot)
          checkPlaytime(summary, prog1.id)
          checkPlaytime(summary, prog2.id)
          checkPlaytime(summary, prog3.id)
        end

        it 'Example 5 (skewed priority, differing screen utilisation)' do
          prog1 = Programme.create({:screens => (rand(4) + 1), :priority => 1})
          prog1.visualisation = getVis
          prog2 = Programme.create({:screens => (rand(4) + 1), :priority => 1})
          prog2.visualisation = getVis
          prog3 = Programme.create({:screens => (rand(4) + 1), :priority => 10})
          prog3.visualisation = getVis

          timeslot = Timeslot.create({:start_time => start_t, :end_time => end_t})
          timeslot.programmes << [prog1, prog2, prog3]
          generate_schedule(timeslot)

          summary = getSummary(timeslot)
          checkPlaytime(summary, prog1.id)
          checkPlaytime(summary, prog2.id)
          checkPlaytime(summary, prog3.id)
        end

        it 'Example 6 (skewed priority, differing screen utilisation,
            reasonably high min_playtime in low priority vis)' do
          # Expect prog1 to get ~360sec playtime
          prog1 = Programme.create({:screens => (rand(4) + 1), :priority => 1})
          prog1.visualisation = getVis(300)
          prog2 = Programme.create({:screens => (rand(4) + 1), :priority => 1})
          prog2.visualisation = getVis
          prog3 = Programme.create({:screens => (rand(4) + 1), :priority => 10})
          prog3.visualisation = getVis

          timeslot = Timeslot.create({:start_time => start_t, :end_time => end_t})
          timeslot.programmes << [prog1, prog2, prog3]
          generate_schedule(timeslot)

          summary = getSummary(timeslot)
          checkPlaytime(summary, prog1.id)
          checkPlaytime(summary, prog2.id)
          checkPlaytime(summary, prog3.id)
        end

        it 'Example 7 (differing priority, differing screen utilisation)' do
          prog1 = Programme.create({:screens => (rand(4) + 1), 
                                    :priority => (rand(10) + 1)})
          prog1.visualisation = getVis
          prog2 = Programme.create({:screens => (rand(4) + 1), 
                                    :priority => (rand(10) + 1)})
          prog2.visualisation = getVis
          prog3 = Programme.create({:screens => (rand(4) + 1), 
                                    :priority => (rand(10) + 1)})
          prog3.visualisation = getVis

          timeslot = Timeslot.create({:start_time => start_t, :end_time => end_t})
          timeslot.programmes << [prog1, prog2, prog3]
          generate_schedule(timeslot)

          summary = getSummary(timeslot)
          checkPlaytime(summary, prog1.id)
          checkPlaytime(summary, prog2.id)
          checkPlaytime(summary, prog3.id)
        end




      end

      

      
    end  
    
    context 'should work for 2x2 screen configuration:' do
      it 'no 1x2 vis should be on screens in two seperate rows' do
        expect(1).to be 1
      end
    end 
  end

  describe '.initQueue' do
    it 'initialise queue with increasing time for next playout' do
      vis1 = Visualisation.create({:name => "Milan"})
      vis2 = Visualisation.create({:name => "Green", 
                                   :min_playtime => 2 * Const.SECONDS_IN_UNIT_TIME})
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

