require 'rails_helper'
include Scheduling
include Const

RSpec.describe Scheduling, :type => :concern do

  Visualisation.create([
    {:name => "Milan"}, 
    {:name => "Green"},
    {:name => "Pink"}, 
    {:name => "Power", :isDefault => true}, 
  ])

  describe '.get_a_default_programme' do
    
    prog = get_a_default_programme
    vis = Visualisation.find(prog.visualisation_id)

    it 'should return a programme containing default visualisation' do
      expect(vis.isDefault).to be true
    end

    it 'should return a programme with lowest priority' do
      expect(prog.priority).to eq(Const.MIN_PRIORITY)
    end

    it 'should return a programme with lowest no. of screen(s)' do
      expect(prog.screens).to eq(Const.MIN_SCREENS)
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

  describe '.preprocess_and_build_queue' do
    
    emptyProgsQueue = preprocess_and_build_queue(emptyProgs)
    underPopulatedProgsQueue = preprocess_and_build_queue(underPopulatedProgs)
    wellPopulatedProgsQueue = preprocess_and_build_queue(wellPopulatedProgs)

    context 'should return a queue which' do
      context 'contain some programmes' do
        it 'for initially empty programme list' do
          expect(emptyProgsQueue.first).to be_truthy # not nil
        end

        it 'for under-populated programme list' do
          expect(underPopulatedProgsQueue.first).to be_truthy
        end

        it 'for well-populated programme list' do
          expect(wellPopulatedProgsQueue.first).to be_truthy
        end
      end
    
      context 'contain programmes in decreasing priority' do
        def checkDecreasingPriority(queue)
          prev = queue.first
          queue.each do |curr|
            expect(prev.priority).to be >= curr.priority
          end
        end

        it 'for initially empty programme list' do
          checkDecreasingPriority(emptyProgsQueue)
        end

        it 'for under-populated programme list' do
          checkDecreasingPriority(underPopulatedProgsQueue)
        end

        it 'for well-populated programme list' do
          checkDecreasingPriority(wellPopulatedProgsQueue)
        end
      end

      context 'contain all programmes in input' do
        def checkInclusion(progs, queue)
          progs.each do |prog|
            expect(queue).to include prog
          end
        end

        it 'for initially empty programme list' do
          checkInclusion(emptyProgs, emptyProgsQueue)
        end
        
        it 'for under-populated programme list' do
          checkInclusion(underPopulatedProgs, underPopulatedProgsQueue)
        end

        it 'for well-populated programme list' do
          checkInclusion(wellPopulatedProgs, wellPopulatedProgsQueue)
        end
      end

      context 'have total screen load greater or equal to NO_OF_SCREENS' do
        it 'for initially empty programme list' do
          expect(get_total_screen_load(emptyProgsQueue)).
            to be >= Const.NO_OF_SCREENS
        end

        it 'for under-populated programme list' do
          expect(get_total_screen_load(underPopulatedProgsQueue)).
            to be >= Const.NO_OF_SCREENS
        end

        it 'for well-populated programme list' do
          expect(get_total_screen_load(wellPopulatedProgsQueue)).
            to be >= Const.NO_OF_SCREENS
        end
      end
    end
  end

  vis = Visualisation.create({:name => 'Test'})
  overridingProg = 
    Programme.create({:screens => Const.NO_OF_SCREENS, :priority => 1})

  vis.programmes << overridingProg

    
  overridingTimeslot = 
    Timeslot.create({
      :start_time => DateTime.new(2014, 9, 1, 12, 0, 0).utc,
      :end_time => DateTime.new(2014, 9, 1, 13, 0, 0).utc
    })

  overridingTimeslot.programmes << overridingProg

  describe '.generate_schedule:' do
    context 'when total screen load equals to NO_OF_SCREENS' do
      context 'and there is 1 programme only (overriding case)' do
        it 'should create schedule with 1 item only' do
          expect(Visualisation.where(name:'Test')).to be 1
          generate_schedule(overridingTimeslot)
          sessions = PlayoutSession.where(start_time:
            DateTime.new(2014, 9, 1, 12, 0, 0).utc..
            DateTime.new(2014, 9, 1, 13, 0, 0))

          expect(sessions.length).to be 1
        end
      end

      context 'and there is 2-4 programs (cycle-around case)' do
          pending ": to finish writing the test"
      end

    end
  end
end



