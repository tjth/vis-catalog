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

emptyProgs = Programme.create([])
underPopulatedProgs = Programme.create([{:screens => 1, :priority => 4}])
wellPopulatedProgs = Programme.create([{:screens => 1, :priority => 4},
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
        def decreasingPriority(queue)
          prev = queue.first
          queue.each do |curr|
            if (prev.priority < curr.priority)
              return false
            end
            prev = curr
          end
          return true
        end

        it 'for initially empty programme list' do
          expect(decreasingPriority(emptyProgsQueue)).to be true
        end

        it 'for under-populated programme list' do
          expect(decreasingPriority(underPopulatedProgsQueue)).to be true
        end

        it 'for well-populated programme list' do
          expect(decreasingPriority(wellPopulatedProgsQueue)).to be true
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

      context 'have total screen load geq NO_OF_SCREENS' do
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

  describe '.generate_schedule' do
    # context 'when total screen load equals to NO_OF_SCREENS'
      # context 'and there is 1 program only (override)'
      # context 'and there is 2-4 programs (cycle around)'
    pending "tests to be implemented"
  end
end



