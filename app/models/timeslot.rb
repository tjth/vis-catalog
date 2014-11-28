class Timeslot < ActiveRecord::Base
  has_many :programmes

  validates :start_time, presence: true
  validates :end_time, presence: true
end
