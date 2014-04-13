require './lib/player'

class ComputerPlayer < Player
  WEAPONS = [
    :energy_weapon,
    :laser,
    :meson_gun,
    :missile,
    :particle_acc,
    :repulsor,
    :sand
    ]
  
  def initialize(options={})
    @defensive_energy = options[:defensive_energy] || false
    @defensive_laser = options[:defensive_laser] || false
    @range_pref = options[:range_pref] || :long
  end  
  
  def assign_batteries(fleet, ship)
    # Returns an array
    batteries = []
    fleet.ships.each do |ship|
      fleet.batteries.each_key do |obj|
        if can_damage?(obj, ship) && can_hit?(obj, ship) && rand(@counter) == 0
          batteries << obj 
        end
      end
    end
    @counter -= 1
    batteries
  end
  
  def assign_damage(choices)
    rand(choices.length)
  end
  
  def assign_defenses(ship, hits)
    # Returns a 2d array, with length equal to hits
    # decide whether to fire beams defensively
    defenses = Array.new(hits.length) { [] }
    missile_inds 
      b.class == Missile && can_damage?(b, ship) ? 1 : 0

    beam_inds = hits.inject(0) do |n, b|
      b.class <= BeamWeapon && can_damage?(b, ship) ? 1 : 0
    end
  end
  
  def assign_to_battle_line?(ship)
    ship.can_fire?
  end
  
  def begin_combat_step
    @counter = enemy.ships.length
  end
  
  def choose_range
    @range = @range_pref
    @range_pref
  end
  
  def see_range(range)
    @range = range
  end
  
  def select_repair(choices)
    if choices.any? { |choice| WEAPONS.include?(choice) }
      choices.index { |choice| WEAPONS.include?(choice) }
    else
      0
    end
  end
  
  private 
  def can_damage?(battery, ship)
    return false if battery.to_hit(ship, @range) > 12
    return true if battery.class == MesonGun
    return true if battery.class == ParticleAccelerator && 
      battery.factor - 9 - ship.armor.to_i / 2 > 0
    mods = ship.armor
    mods += 6 if battery.factor < 10
    mods -= 6 if battery.class == Missile && battery.type == :nuc
    mods -= 2 if battery.class == Laser && battery.type == :pulse
    mods < 20
  end
end