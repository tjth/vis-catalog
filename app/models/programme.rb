class Programme < ActiveRecord::Base
  has_one :visualisation
  belongs_to :timeslot
end
