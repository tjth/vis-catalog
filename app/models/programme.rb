class Programme < ActiveRecord::Base
  belongs_to :visualisation
  belongs_to :timeslot

  validates :screens, presence: true
  validates :priority, presence: true
  validates :visualisation_id, presence: true
  validates :timeslot_id, presence: true


  def duration
    return self.visualisation.min_playtime
  end

  def period
    return self.visualisation.min_playtime / self.priority.to_f
  end

  def <=>(otherProg)
    durationDiff =
      self.visualisation.min_playtime - otherProg.visualisation.min_playtime
    return (durationDiff == 0) ? (rand(2) * 2 - 1) : (durationDiff <=> 0)
  end

end
