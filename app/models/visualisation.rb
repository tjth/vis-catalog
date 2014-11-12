class Visualisation < ActiveRecord::Base
  enum content_type: [ :file, :weblink ]
  belongs_to :user
  has_many :programmes
  has_many :playout_sessions
  attr_default :approved, false
  attr_default :isDefault, false
end
