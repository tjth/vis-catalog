require 'rails_helper'
include Scheduling

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



RSpec.describe Scheduling, :type => :concern do

  describe '.get_a_default_programme' do
    
    prog = get_a_default_programme
    vis = Visualisation.find(prog.visualisations_id)

    it 'should return a programme containing default visualisation' do
      expect(vis.isDefault).to be true
    end

    it 'should return a programme with lowest (1) priority' do
      expect(prog.priority).to eq(1)
    end

    it 'should return a programme with lowest no. of (1) screen(s)' do
      expect(prog.screens).to eq(1)
    end

  end

  describe '.get_total_screen_load' do
    progs1 = Programme.create([{:screens => 1}])
    progs2 = Programme.create([{:screens => 1}, {:screens => 2}])
    progs3 = Programme.create([{:screens => 1}, {:screens => 4}, 
                               {:screens => 3}, {:screens => 2}])
    
    it 'should return the sum of all programme\'s screens' do
      expect(get_total_screen_load(progs1)).to be 1
      expect(get_total_screen_load(progs2)).to be 3
      expect(get_total_screen_load(progs3)).to be 10
    end
  end

  describe '.preprocess_and_build_queue' do
    
    
  end

  describe '.generate_schedule' do
    # context 'when total screen load equals to NO_OF_SCREENS'
      # context 'and there is 1 program only (override)'
      # context 'and there is 2-4 programs (cycle around)'
    pending "tests to be implemented"
  end
end



