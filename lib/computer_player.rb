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
    super(options)
  end  
  
  def assign_batteries(fleet, ship)
    # Returns an array
    batteries = []
    fleet.battle_line.each do |firing_ship|
      firing_ship.batteries.each_value do |obj|
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
    defenses = Array.new(hits.length) { [] }
    missile_inds = hits.each_index.select { |i| hits[i].class == Missile }
    beam_inds = hits.each_index.select { |i| hits[i].class <= BeamWeapon }

    assign_defense!(ship, missile_inds, :repulsor, defenses) 
    assign_defense!(ship, missile_inds + beam_inds, :sand, defenses)
    assign_defense!(ship, missile_inds, :energy_weapon, defenses)
    assign_defense!(ship, missile_inds, :laser, defenses)
    defenses
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
  
  def see_lines(fleet)
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
  def assign_defense!(ship, hit_inds, type, defenses)
    battery = ship.batteries[type]
    l = hit_inds.length
    
    return if (type == :energy_weapon && !@defensive_energy) || 
      (type == :laser && !@defensive_laser) || !battery || l == 0
      
    count = battery.count
    (0...count).each { |i| defenses[hit_inds[i % l]] << battery }
  end
  
  def can_damage?(battery, ship)
    return false if battery.class == Repulsor || battery.class == SandCaster
    return true if battery.class == MesonGun
    return true if battery.class == ParticleAccelerator && 
      battery.factor - 9 - ship.armor.to_i / 2 > 0
    mods = ship.armor
    mods += 6 if battery.factor < 10
    mods -= 6 if battery.class == Missile && battery.type == :nuc
    mods -= 2 if battery.class == Laser && battery.type == :pulse
    mods < 20
  end
  
  def can_hit?(battery, ship)
    return false if battery.class == Repulsor || battery.class == SandCaster
    battery.to_hit(ship, @range) <= 12
  end
end