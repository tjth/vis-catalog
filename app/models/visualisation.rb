class Visualisation < ActiveRecord::Base
  enum content_type: [ :file, :weblink ]
  belongs_to :user
  belongs_to :programme
  attr_default :approved, false

  #some filters!
  scope :approved, -> (boolean) {where approved: boolean}

end
