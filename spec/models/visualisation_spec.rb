require 'rails_helper'

RSpec.describe Visualisation do

  context 'by default' do
    it 'should not be approved' do
      vis = Visualisation.create({:name => 'test', :content => 'test.html'})
      expect(vis.approved).to be_false
    end
  end
end

