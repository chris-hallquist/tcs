require './lib/damage'
require './lib/ship'
require './lib/TCS'

class Battery
  attr_accessor :factor, :count, :fired_count, :comp
  
  def initialize(factor, count, comp)
    @factor = factor
    @count = count
    @comp = comp
    @fired_count = 0
    spinal?
    uniq?
  end
  
  def defenses_penetrated?(target, active_ds)
    raise "Not implemented"
  end
  
  def dms_to_penetrate
    comp + (self.class == EnergyWeapon ? 2 : 0)
  end
  
  def energy
    0
  end
  
  def hit?(target, range=nil)
    factor > 0 &&
      TCS.roll + standard_dms_to_hit(target) + range_dm(range) >= attack_table
  end
  
  def size_modifiers(target)
    size = target.tonnage_code
    if size == 0
      return -2
    elsif size < 11
      return -1
    elsif size < 20
      return 0
    elsif size < 24
      return 1
    else
      return 2
    end
  end    

  def spinal?
    false
  end

  def standard_dms_to_hit(target)
    total = comp 
    total -= target.agility_with_tanks
    total += size_modifiers(target)
  end
  
  def uniq?
    @uniq = count == 1 if @uniq == nil
    @uniq
  end
end

class BeamWeapon < Battery
  def attack_table
    8 - factor / 2
  end
  
  def defenses_penetrated?(target, active_ds)
    active_ds.none? do |d|
      d.class == SandCaster && d.factor > 0 &&
        TCS.roll + dms_to_penetrate >= to_penetrate(d) 
    end
  end
  
  def to_penetrate(defense)
    defense.factor + 8 - factor
  end
end

class EnergyWeapon < BeamWeapon
  # Will assume fusion guns not in bays, for now at least
  def cost
    factor * turrets * 1_000_000
  end
  
  def energy
    factor * turrets * 2
  end

  def range_dm(range)
    range == :long ? 99 : 0
  end

  def roll_damage(target, firing_player)
    Damage.surface_explosion(target.shadow, firing_player, 6 + target.armor)
  end

  def tons
    factor * turrets * 2
  end
  
  def turrets
    @turrets ||= Hash.new(0).merge({ 4 => 1, 
                                     5 => 4, 
                                     6 => 10, 
                                     7 => 11, 
                                     8 => 20 })[factor]
  end
end

class Laser < BeamWeapon
  attr_accessor :type
  
  def initialize(factor, count, comp, type=:beam)
    super(factor, count, comp)
    @type=type
  end
  
  def cost
    count * (type == :pulse ? turrets * 0.5 : turrets) * 1_000_000
  end
  
  def energy
    count * turrets
  end
  
  def range_dm
    range == :short ? -1 : 0
  end
  
  def roll_damage(target, firing_player)
    mods = 6 + target.armor + (type == :pulse ? -2 : 0)
    Damage.surface_explosion(target.shadow, firing_player, mods)
  end
  
  def tons
    count * turrets
  end
  
  def turrets
    if type == :pulse
      return @turrets ||= Hash.new(0).merge({ 1 => 1, 
                                              2 => 3, 
                                              3 => 6, 
                                              4 => 10, 
                                              5 => 21,
                                              6 => 30 })[factor]
    else
      return @turrets ||= Hash.new(0).merge({ 1 => 1, 
                                              2 => 2, 
                                              3 => 3, 
                                              4 => 6, 
                                              5 => 10,
                                              6 => 15,
                                              7 => 21,
                                              8 => 30 })[factor]
    end
  end
end

class MesonGun < Battery
  def attack_table
    if factor < 3
      return 9
    elsif factor < 13
      return 9 - (factor + 2) / 3
    else
      return 4
    end
  end

  def cost
    return [10_000,
            12_000,
            3_000,
            5_000,
            800,
            1_000,
            400,
            600,
            400,
            10_000,
            3_000,
            800,
            600,
            5_000,
            1_000,
            800,
            2_000,
            1_000][factor - 10] * 1_000_000
  end
  
  def defenses_penetrated?(target, active_ds)
    penetrate_screen?(target) && penetrate_config?(target)
  end
  
  def energy
    return [500,
            600,
            600,
            700,
            800,
            800,
            900,
            900,
            1_000,
            1_000,
            1_000,
            1_000,
            1_100,
            1_100,
            1_100,
            1_200,
            1_2000][factor - 10]
  end

  def penetrate_config?(target)
    TCS.roll + dms_to_penetrate >= to_penetrate_config(target)
  end
  
  def penetrate_screen?(target)
    if target.meson_screen == 0
      return true
    elsif factor < 10
      TCS.roll + dms_to_penetrate >= 16 - factor / 2
    else
      TCS.roll + dms_to_penetrate >= 9 - (factor - 10) / 2
    end
  end
  
  def roll_damage(target, firing_player)
    factor < 10 ? mod =  6 : mod = 0
    Damage.radiation(target.shadow, firing_player, mod)
    Damage.interior_explosion(target.shadow, firing_player, mod)
  end
  
  def to_penetrate_config(target)
    if factor < 10
      case target.config
      when 1
        (39 - factor) / 3
      when 2
        (33 - factor) / 3
      when 3
        (31 - factor) / 3
      when 4
        (23 - factor) / 3
      when 5
        (19 - factor) / 3
      when 6
        (25 - factor) / 3
      when 7
        (47 - factor) / 3
      when 8
        (15 - factor) / 3
      when 9
        (43 - factor) / 3
      end
    else
      case target.config
      when 1
        8 - (factor - 10) / 3
      when 2
        7 - (factor - 9) / 3
      when 3
        6 - (factor - 8) / 3
      when 4
        3 - (factor - 9) / 3
      when 5
        2 - (factor - 8) / 3
      when 6
        5 - (factor - 10) / 3
      when 7
        11 - (factor - 9) / 3
      when 8
        0
      when 9
        10 - (factor - 8) / 3
      end
    end
  end

  def range_dm(range)
    range == :short ? 2 : 0
  end
  
  def spinal?
    true
  end
  
  def tons    
    return [5_000,
            8_000,
            2_000,
            5_000,
            1_000,
            2_000,
            1_000,
            2_500,
            1_000,
            8_500,
            5_000,
            4_000,
            2_000,
            8_000,
            7_000,
            5_000,
            8_000,
            7_000][factor - 10]
  end
end

class Missile < Battery
  def initialize(factor, count, comp, type=:nuc)
    super(factor, count, comp)
    @type=type
  end
  
  def attack_table
    7 - (factor + 1) / 2
  end
  
  def cost
    if factor == 9
      return count * 20_000_000
    elsif factor == 8
      return count * 12_000_000
    else
      return count * turrets * 750_000
    end
  end
  
  def defenses_penetrated?(target, active_ds)
    return false unless penetrate_nuc_damp?(target)
    active_ds.none? do |d|
      if (d.class == SandCaster || d.class <= BeamWeapon) && d.factor > 0
        TCS.roll + dms_to_penetrate >= to_penetrate_sob(d)
      elsif d.class == Repulsor && d.factor > 0
        TCS.roll + dms_to_penetrate >= to_penetrate_repulsor(d)
      else
        true
      end
    end
  end
  
  def penetrate_nuc_damp?(target)
    if target.nuc_damp == 0 || type != :nuc
      return true
    else
      TCS.roll + dms_to_penetrate >= 11 - factor
    end
  end
  
  def range_dm(range)
    range == :short ? -1 : 0
  end
  
  def roll_damage(target, firing_player)
    se_mod = target.armor + (type == :nuc ? 0 : 6)
    Damage.surface_explosion(target.shadow, firing_player, se_mod)
    Damage.radiation(target.shadow, firing_player, target.armor) if type == :nuc
  end
  
  def to_penetrate_repulsor(d)
    15 - factor + d.factor
  end
  
  def to_penetrate_sob(d)
    5 - factor + d.factor
  end
  
  def tons
    if factor == 9
      return count * 100
    elsif factor == 8
      return count * 50
    else
      return count * turrets
    end
  end

  def turrets
    @turrets ||= Hash.new(0).merge({ 1 => 1, 
                                     2 => 3, 
                                     3 => 6, 
                                     4 => 12, 
                                     5 => 18,
                                     6 => 30 })[factor]
  end
end

class ParticleAccelerator < Battery
  def attack_table
    if factor < 3
      return 10 - factor
    elsif factor < 10
      return 9 - (factor + 1)/2
    elsif factor < 15
      return 3
    elsif factor < 20
      return 2
    elsif factor < 25
      return 1
    else
      return 0
    end
  end
  
  def cost
    if factor <= 4
      return count * 20_000_000
    elsif factor <= 8
      return count * 35_000_000
    else
      return [3_500,
               3_000,
               2_400,
               1_500,
               1_200,
               1_200,
               800,
               500,
               3_000,
               2_000,
               1_600,
               1_200,
               1_000,
               800,
               2_000,
               1_500,
               1_200,
               1_000][factor - 10] * 1_000_000
    end
  end
  
  def defenses_penetrated?(target, defenses)
    true
    # No defenses are possible against a particle accelerator
  end
  
  def energy
    if factor <= 4
      return count * 30
    elsif factor <= 9
      return count * 60
    else
      return (((factor - 10) / 3) + 5) * 100
    end
  end
  
  def range_dm(range)
    0
  end
  
  def roll_damage(target, firing_player)
    mods = target.armor + (factor < 10 ? 6 + 0)
    Damage.surface_explosion(target.shadow, firing_player, mods)
    Damage.radiation(target.shadow, firing_player, mods)
  end
  
  def spinal?
    @spinal = factor > 9 if @spinal == nil
    @spinal
  end
  
  def to_hit(target, range)
    attack_table - standard_dms_to_hit(target)
  end

  def tons
    if factor == 4
      return count * 50
    elsif factor == 8
      return count * 100
    elsif factor > 9
      return [5_500,
              5_000,
              4_500,
              4_000,
              3_500,
              3_000,
              2_500,
              2_500,
              5_000,
              4_500,
              4_000,
              3_500,
              3_000,
              2_500,
              4_500,
              4_000,
              3_500,
              3000][factor - 10]
    else
      return 0
    end
  end  
end

class Repulsor < Battery
end

class SandCaster < Battery
  def cost
    count * turrets * 250_000
  end
  
  def tons
    count * turrets
  end

  def turrets
    @turrets ||= Hash.new(0).merge({ 3 => 1, 
                                     4 => 3, 
                                     5 => 6, 
                                     6 => 8, 
                                     7 => 10,
                                     8 => 20,
                                     9 => 30 })[factor]
  end
end