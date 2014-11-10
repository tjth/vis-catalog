require 'rails_helper'
include Scheduling

RSpec.describe Scheduling, :type => :concern do

  Visualisation.create([{:name => 'Default one',
                         :isDefault => true},
                        {:name => 'Not the default one',
                         :isDefault => false},
                        {:name => 'Not default as well',
                         :description => 'Lorem ipsum dolor sit amet.',
                         :isDefault => false},
                        {:name => 'Another default one',
                         :isDefault => true}])

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
    pending "test to be implemented"
  end

  describe '.preprocess_and_build_queue' do
    pending "tests to be implemented"
  end

  describe '.generate_schedule' do
    # context 'when total screen load equals to NO_OF_SCREENS'
      # context 'and there is 1 program only (override)'
      # context 'and there is 2-4 programs (cycle around)'
    pending "tests to be implemented"
  end
end
