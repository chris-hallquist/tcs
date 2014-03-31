class ComputerPlayer
  def initialize(range_pref=:long)
    @range_pref = range_pref
  end
  
  def assign_damage(choices)
    rand(choices.length)
  end
  
  def choose_range
    @range_pref
  end
end