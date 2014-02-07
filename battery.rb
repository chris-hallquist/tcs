class Battery
  def initialize(ship)
    @ship = ship
    @ship.ship << this
  end
  
  def fire(target)
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
    total = @ship.relative_computer_size 
    total -= target.agility_rating 
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
end

class ParticleAccelerator < Battery
  attr_reader :factor
  
  def initialize(factor)
    @factor = factor
  end
  
  def attack_table
    if factor.class == Fixnum
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
  
  def to_hit(target)
    attack_table + standard_dms_to_hit
  end
end