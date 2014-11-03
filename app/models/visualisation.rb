class Visualisation < ActiveRecord::Base
  after_initialize :set_default  
  enum content_type: [ :file, :weblink ]
  belongs_to :user

  private
    def set_default
      self.approved = false
    end
end
