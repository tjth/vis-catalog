class Timeslot < ActiveRecord::Base
  enum weekday: [ :Monday, :Tuesday, :Wednesday, :Thursday, :Friday, :Saturday, :Sunday ]
  has_many :programmes
end
