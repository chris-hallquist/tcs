require 'set'

class Ship
  attr_accessor :agility, :batteries, :comp, :config
  
  HULL_PRICE_MULTIPLIERS = [
    nil,
    120_000, 
    110_000, 
    100_000, 
    60_000, 
    70_000, 
    80_000, 
    50_000,
    900,
    750
    ]
  
  def initialize(options={})
    @aux_bridge = options[:aux_bridge]
    @comp = options[:comp]
    @comp_type = options[:comp_type]
    @config = options[:config]
    @drop_tanks = options[:drop_tanks]
    @jump = options[:jump]
    @jump_fuel = options[:jump_fuel]
    @maneuver = options[:maneuver]
    @power = options[:power]
    @scoops = options[:scoops]
    @tons = options[:tons]
    status = {}
  end
  
  def bridge_cost
    5_000 * @tons * (1 + @aux_bridge)
  end
  
  def bridge_tons
    [20, @tons * 0.02].max * (1 + @aux_bridge)
  end
  
  def comp_cost
    if @comp_type == :fib
      [0, 3, 14, 27, 45, 68, 83, 100, 140, 200][@comp] * 1_000_000
    elsif @comp_type == :bis
      [0, 4, 18][@comp] * 1_000_000
    else
      [0, 2, 9, 18, 30, 45, 55, 80, 110, 140][@comp] * 1_000_000
    end
  
  def comp_energy
    [0, 0, 0, 1, 2, 3, 5, 7, 9, 12][@comp]
  end
  
  def comp_tons
    @comp < 6 ? base = @comp : base = @comp * 2 - 5
    @comp_type == :fib ? base * 2 : base
  end
  
  def drop_tank_cost
    @drop_tanks > 0 ? 1_000 * (@drop_tanks + 10) : 0
  end
  
  def energy
    @tons * @power * 0.01
  end
  
  def hull_cost
    @tons * HULL_PRICE_MULTIPLIERS[@config]
  end
  
  def jump_cost
    jump_tons * 4_000_000
  end
  
  def jump_tons
    @jump > 0 ? @tons * (@jump + 1) / 100.0 + @jump_fuel : 0
  end
  
  def maneuver_cost
    if @maneuver == 1
      multiplier = 1_500_000
    elsif @maneuver == 2
      multiplier = 700_000
    else
      multiplier = 500_000
    end
    multiplier * maneuver_tons
  end
  
  def maneuver_tons
    @tons * (@maneuver * 3 - 1) * 0.01
  end
  
  def power_cost
    power_tons * 3_000_000
  end
  
  def power_tons
    @tons * @power * 4 / 100.0 # Includes fuel
  end
  
  def scoops_cost
    @scoops ? @tons * 1_000 : 0
  end
  
  def size
    @size ||= size!
  end
  
  def size!
    if @tons < 1_000
      return @tons / 100
    elsif @tons < 10_000
      return ("A".."J").to_a[@tons / 1_000 - 1]
    elsif @tons < 50_000
      return ("K".."N").to_a[@tons / 10_000 - 1]
    elsif @tons < 75_000
      return "P"
    elsif @tons < 700_000
      return ("Q".."V").to_a[@tons / 100_000]
    elsif @tons < 900_000
      return "W"
    elsif @tons < 1_000_000
      return "X"
    else
      return "Y"
    end
  end
  
  def validate_jump_fuel
    (@jump_fuel + @drop_tanks) >= (@tons + @drop_tanks) * @jump / 10.0
  end
end

class SmallCraft < Ship
  def initialize(options={})
    super(options)
    @jump = 0 # Small craft don't have jump drives
  end
end