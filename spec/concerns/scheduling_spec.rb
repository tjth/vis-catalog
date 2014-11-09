require 'rails_helper'
include Scheduling

RSpec.describe Scheduling, :type => :concern do


  describe '.get_a_default_programme' do
    Visualisation.create({:name => 'default one',
                          :isDefault => true})
    Visualisation.create({:name => 'not the default one',
                          :isDefault => false})
    Visualisation.create({:name => 'not default as well',
                          :description => 'Lorem ipsum dolor sit amet.',
                          :isDefault => false})
    prog = get_a_default_programme
    vis = Visualisation.find(prog.visualisations_id)

    it 'should return a programme containing default visualisation' do
      expect(vis.isDefault).to be true
      expect(vis.name).to eq('default one')
    end

    it 'should return a programme with lowest (1) priority' do
      expect(prog.priority).to eq(1)
    end

    it 'should return a programme with lowest no. of (1) screen(s)' do
      expect(prog.screens).to eq(1)
    end

  end
end
