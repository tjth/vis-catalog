require 'rails_helper'
include Scheduling
include Const

# Seeding
for i in 1..5
    Visualisation.create([
      {:name => "Milan", 
       :link => "/assets/dummy/milan.png", 
       :description => "Lorem ipsum dolor sit amet, consectetur adipiscing 
                        elit, sed do eiusmod tempor incididunt ut labore et 
                        dolore magna aliqua. Ut enim ad minim veniam, quis 
                        nostrud exercitation ullamco laboris nisi ut aliquip 
                        ex ea commodo consequat."}, 
      {:name => "Green",
       :link => "/assets/dummy/green.png",
       :description => "Lorem ipsum dolor sit amet, consectetur adipiscing 
                        elit, sed do eiusmod tempor incididunt ut labore et 
                        dolore magna aliqua. Ut enim ad minim veniam, quis 
                        nostrud exercitation ullamco laboris nisi ut aliquip 
                        ex ea commodo consequat."},
      {:name => "Pink", 
       :link => "/assets/dummy/pink.png",
       :description => "Lorem ipsum dolor sit amet, consectetur adipiscing 
                        elit, sed do eiusmod tempor incididunt ut labore et 
                        dolore magna aliqua. Ut enim ad minim veniam, quis 
                        nostrud exercitation ullamco laboris nisi ut aliquip 
                        ex ea commodo consequat."}, 
      {:name => "Power", 
       :link => "/assets/dummy/power.png",
       :isDefault => true,
       :description => "Lorem ipsum dolor sit amet, consectetur adipiscing 
                        elit, sed do eiusmod tempor incididunt ut labore et 
                        dolore magna aliqua. Ut enim ad minim veniam, quis 
                        nostrud exercitation ullamco laboris nisi ut aliquip 
                        ex ea commodo consequat."}, 
    ])
end

progs1 = Programme.create([])
progs2 = Programme.create([{:screens => 1, :priority => 4}])
progs3 = Programme.create([{:screens => 1, :priority => 4},
                           {:screens => 4, :priority => 3}, 
                           {:screens => 3, :priority => 2},
                           {:screens => 2, :priority => 1}])



RSpec.describe Scheduling, :type => :concern do

  describe '.get_a_default_programme' do
    
    prog = get_a_default_programme
    vis = Visualisation.find(prog.visualisations_id)

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

  describe '.get_total_screen_load' do
    
    it 'should return the sum of all programme\'s screens' do
      expect(get_total_screen_load(progs1)).to be 0
      expect(get_total_screen_load(progs2)).to be 1
      expect(get_total_screen_load(progs3)).to be 10
    end
  end

  describe '.preprocess_and_build_queue' do
    
    queue1 = preprocess_and_build_queue(progs1)
    queue2 = preprocess_and_build_queue(progs2)
    queue3 = preprocess_and_build_queue(progs3)

    context 'should return a queue which' do
      it 'contain some programmes' do
        expect(queue1.first).to be_truthy # not nil
        expect(queue2.first).to be_truthy
        expect(queue3.first).to be_truthy
      end
    
      it 'contain programmes in decreasing priority' do
        temp = queue1.first
        queue1.each do |queue_elem|
          expect(queue_elem.priority).to >= temp.priority
          temp = queue_elem
        end
      end

      it 'contain all programmes in input' do
        pending ": write the test"
      end

      it 'have total screen load geq NO_OF_SCREENS' do
        expect(get_total_screen_load(queue1)).to be >= Const.NO_OF_SCREENS
        expect(get_total_screen_load(queue2)).to be >= Const.NO_OF_SCREENS
        expect(get_total_screen_load(queue3)).to be >= Const.NO_OF_SCREENS
      end
    end
  end

  describe '.generate_schedule' do
    # context 'when total screen load equals to NO_OF_SCREENS'
      # context 'and there is 1 program only (override)'
      # context 'and there is 2-4 programs (cycle around)'
    pending "tests to be implemented"
  end
end



