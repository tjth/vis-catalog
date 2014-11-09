class TimeslotsController < ApplicationController
  include Scheduling

  def test
    @test = testing
  end
end
