require 'rails_helper'
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
      expect(prog.screens).to eq(Const.MIN_SCREENS)
    end
  end

  emptyProgs = Programme.create([])
  underPopulatedProgs = Programme.create([{:screens => 1, :priority => 4}])
  wellPopulatedProgs = Programme.create([{:screens => 1, :priority => 4},
                                         {:screens => 4, :priority => 3}, 
                                         {:screens => 3, :priority => 2},
                                         {:screens => 2, :priority => 1}])

  emptyProgsQueue = preprocess_and_build_queue(emptyProgs)
  underPopulatedProgsQueue = preprocess_and_build_queue(underPopulatedProgs)
  wellPopulatedProgsQueue = preprocess_and_build_queue(wellPopulatedProgs)

  describe '.get_total_screen_load' do
    it 'should return the sum of all programme\'s screens' do
      expect(get_total_screen_load(emptyProgs)).to be 0
      expect(get_total_screen_load(underPopulatedProgs)).to be 1
      expect(get_total_screen_load(wellPopulatedProgs)).to be 10
    end
  end

  start_time = DateTime.new(2014, 9, 1, 12, 0, 0).utc
  end_time = DateTime.new(2014, 9, 1, 13, 0, 0).utc

  describe '.clean_old_sessions' do
    it 'should clean all the existing session within the timeslot' do
      for i in 0..2
      PlayoutSession.create(
        {:start_time => DateTime.new(2014, 9, 1, 12, i, 0).utc,
         :end_time => DateTime.new(2014, 9, 1, 12, i+1, 0).utc})
      end

      clean_old_sessions(start_time, end_time)

      sessions = PlayoutSession.where(start_time: start_time...end_time)
      expect(sessions.length).to be 0
    end
  end

  describe '.generate_schedule' do
    context 'when total screen load equals to NO_OF_SCREENS' do
      context 'and there is 1 programme only (overriding case)' do
        
        it 'should create schedule with 1 item only' do
          vis = Visualisation.create({:name => 'Test'})
          overridingProg = Programme.create({:screens => Const.NO_OF_SCREENS,
                                             :priority => 1})
          vis.programmes << overridingProg

          overridingTimeslot = Timeslot.create({
            :start_time => start_time, :end_time => end_time})
          overridingTimeslot.programmes << overridingProg

          generate_schedule(overridingTimeslot)
          sessions = PlayoutSession.where(start_time: start_time...end_time)

          expect(sessions.length).to be 1
        end
      end

      context 'and there is 2-4 programs (cycle-around case)' do
          pending ": to finish writing the test"
      end

    end
  end

end

