class Programme < ActiveRecord::Base
  belongs_to :visualisation
  belongs_to :timeslot
end
