class Visualisation < ActiveRecord::Base
  enum content_type: [ :file, :weblink ]
  enum vis_type: [ :vis, :advert ]

  belongs_to :user
  has_many :programmes
  has_many :playout_sessions
  attr_default :approved, false
  attr_default :isDefault, false

  #some filters!
  scope :approved, -> (boolean) {where approved: true}
  scope :vis, ->  {where vis_type: "vis"}

end
