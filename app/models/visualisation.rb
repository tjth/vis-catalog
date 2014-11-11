class Visualisation < ActiveRecord::Base
  enum content_type: [ :file, :weblink ]
  attr_default :approved, false
  attr_default :isDefault, false
end
