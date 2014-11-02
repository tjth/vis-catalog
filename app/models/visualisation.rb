class Visualisation < ActiveRecord::Base
  mount_uploader :avatar, FileUploader
end
