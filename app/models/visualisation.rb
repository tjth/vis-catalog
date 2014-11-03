class Visualisation < ActiveRecord::Base
  mount_uploader :avatar, FileUploader
  
  enum content_type: [ :file, :weblink ]

  belongs_to :user
end
