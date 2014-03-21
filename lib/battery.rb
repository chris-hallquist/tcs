require './lib/ship'

class Battery
  attr_accessor :factor
  
  def initialize(factor)
    @factor = factor
  end
  
  def defenses_penetrated?(target)
    raise "Not implemented"
  end
  
  def fire(target)
    if roll > to_hit(target) && defenses_penetrated?
      # proceed to the damage tables
    end
  end

  def roll(n=2)
    sum = 0
    n.times { sum += rand(6) + 1 }
    sum
  end
  
  def size_modifiers(target)
    size = target.size
    if size.class == Fixnum
      return -2 if size == 0
      return -1
    else
      return -1 if size == "A"
      return 0 if ("B".."K").include?(size)
      return 1 if ("L".."P").include?(size)
      return 2
    end
  end    

  def standard_dms_to_hit(target)
    total = @ship.comp 
    total -= target.agility
    total += size_modifiers(target)
  end

  def to_hit
    raise "Not implemented"
  end  
end

class BeamWeapon < Battery
end

class EnergyWeapon < BeamWeapon
  # Will assume fusion guns not in bays, for now at least
  def cost
    turrets * 1_000_000
  end
  
  def energy
    turrets * 2
  end

  def tons
    turrets * 2
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
  
  def initialize(factor, type=:beam)
    super(factor)
    @type=type
  end
  
  def cost
    (type == :pulse ? turrets * 0.5 : turrets) * 1_000_000
  end
  
  def energy
    turrets
  end
  
  def tons
    turrets
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
            1_000][factor - 10] * 10_000_000
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

class Missiles < Battery
  def initialize(factor, type=:nuc)
    super(factor)
    @type=type
  end
  
  def cost
    if factor == 9
      return 20_000_000
    elsif factor == 8
      return 12_000_000
    else
      return turrets * 750_000
    end
  end
  
  def tons
    if factor == 9
      return 100
    elsif factor == 8
      return 50
    else
      return turrets
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
    if factor.is_a? Fixnum
      if factor < 3
        return 10 - factor
      else
        return 9 - (factor + 1)/2
      end
    else
      if ("A".."E").include?(factor)
        return 3
      elsif ("F".."K").include?(factor)
        return 2
      elsif ("L".."Q").include?(factor)
        return 1
      else
        return 0
      end
    end
  end
  
  def cost
    if factor <= 4
      return 20_000_000
    elsif factor <= 8
      return 35_000_000
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
  
  def defenses_penetrated?(target)
    true
    # No defenses are possible against a particle accelerator
  end
  
  def energy
    if factor <= 4
      return 30
    elsif factor <= 9
      return 60
    else
      return (((factor - 10) / 3) + 5) * 100
    end
  end
  
  def roll_damage
  
  end
  
  def spinal?
    factor.is_a? String
  end
  
  def tons
    if factor == 4
      return 50
    elsif factor == 8
      return 100
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
  
  def to_hit(target)
    attack_table + standard_dms_to_hit
  end
end

class SandCaster < Battery
  def cost
    turrets * 250_000
  end
  
  def tons
    turrets
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