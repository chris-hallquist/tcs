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

class MissileAttack < Battery
end

class BeamWeapon < Battery
end

class MesonGun < Battery
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
  
  def defenses_penetrated?(target)
    true
    # No defenses are possible against a particle accelerator
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
    end
  end
  
  def to_hit(target)
    attack_table + standard_dms_to_hit
  end
end