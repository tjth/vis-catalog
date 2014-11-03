require 'rails_helper'

RSpec.describe User do
  it 'should have a username' do
    user = User.create(:username => 'test')
    expect(user.username).to eq('test')
  end

  it 'should have a name' do
    user = User.create(:name => 'John Doe')
    expect(user.name).to eq('John Doe')
  end

  it 'should not be admin by default' do
    user = User.create({:name => 'John Doe', :username => 'test'})
    expect(user.admin).to be_false
  end
end
