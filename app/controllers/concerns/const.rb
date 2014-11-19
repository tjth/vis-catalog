module Const
  extend ActiveSupport::Concern

  def self.NO_OF_SCREENS
    4
  end

  def self.MIN_SCREENS
    1
  end

  def self.MIN_PRIORITY
    1
  end

  def self.SECONDS_IN_UNIT_TIME
    60
  end

  def self.OVERRIDING_QUEUE_LENGTH
    1
  end

  def self.MIN_CYCLE_AROUND_QUEUE_LENGTH
    2
  end
  
  def self.MAX_CYCLE_AROUND_QUEUE_LENGTH
    4
  end

  def self.MIN_SCREEN_NUMBER
    1
  end

end
