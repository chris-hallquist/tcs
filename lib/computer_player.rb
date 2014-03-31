class ComputerPlayer
  WEAPONS = [
    :energy_weapon
    :laser,
    :meson_gun,
    :missile,
    :particle_acc,
    :repulsor,
    :sand
    ]
  
  def initialize(range_pref=:long)
    @range_pref = range_pref
  end
  
  def assign_damage(choices)
    rand(choices.length)
  end
  
  def assign_to_battle_line?(ship)
    ship.can_fire?
  end
  
  def choose_range
    @range_pref
  end
  
  def select_repair(choices)
    if choices.any? { |choice| WEAPONS.include?(choice) }
      choices.index { |choice| WEAPONS.include?(choice) }
    else
      0
    end
  end
end