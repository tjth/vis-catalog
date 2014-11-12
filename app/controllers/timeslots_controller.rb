class TimeslotsController < ApplicationController
  include Scheduling

  def test
    @test = get_a_default_programme
  end
end
