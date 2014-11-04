class Visualisation < ActiveRecord::Base
  enum content_type: [ :file, :weblink ]
  belongs_to :user

  attr_default :approved, false
end
