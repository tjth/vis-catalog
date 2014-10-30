class Visualisation < ActiveRecord::Base
  enum content_type: [ :file, :weblink ]
end
