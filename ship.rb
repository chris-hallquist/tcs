require 'set'

class Ship
  attr_accessor :armor, :comp, :config, :crew_code, :drop_tanks, :energy_weapons
  attr_accessor :energy_weapon_count, :fighters, :jump, :lasers, :laser_count
  attr_accessor :maneuver, :meson_gun, :meson_gun_count, :meson_screen
  attr_accessor :meson_screen_count, :missiles, :missle_count, :nuc_damp
  attr_accessor :nuc_damp_count, :particle_acc, :particle_acc_count
  attr_accessor :force_field, :force_field_count, :power,  :repulsors 
  attr_accessor :repulsor_count, :sand, :sand_count, :status, :tons
    
  def initialize(usp, batteries, drop_tanks, fuel, tons)
    # TODO: Auxillary bridge, scoops
    @armor = usp[11]
    @cargo = cargo
    @comp = usp[8]
    @config = usp[4]
    @crew_code = usp[9]
    @drop_tanks = drop_tanks
    @energy_weapons = usp[19]
    @energy_weapon_count = batteries[7]
    @figters = usp[24]
    @fuel = fuel
    @jump = usp[5].to_i
    @lasers = usp[18]
    @laser_count = batteries[6]
    @maneuver = usp[6].to_i
    @meson_gun = usp[21]
    @meson_gun_count = batteries[9]
    @meson_screen = usp[13]
    @meson_screen_count = batteries[1]
    @missiles = usp[22]
    @missile_count = batteries[10]
    @nuc_damp = usp[14]
    @nuc_damp_count = batteries[2]
    @particle_acc = usp[20]
    @particle_acc_count = batteries[8]
    @force_field = usp[15]
    @force_field_count = batteries[3]
    @power = Ship.read_usp(usp[7])
    @repulsors = usp[16]
    @repulsor_count = batteries[4]
    @sand = usp[12]
    @sand_count = batteries[0]
    @status = {}
    @tons = tons
  end
  
  def bridge_cost
    5_000 * @tons
  end
  
  def bridge_tons
    [20, @tons * 0.02].max
  end
  
  def commanding_officers
  end
  
  def comp_cost
    if @comp_type == :fib
      [0, 3, 14, 27, 45, 68, 83, 100, 140, 200][@comp] * 1_000_000
    elsif @comp_type == :bis
      [0, 4, 18][@comp] * 1_000_000
    else
      [0, 2, 9, 18, 30, 45, 55, 80, 110, 140][@comp] * 1_000_000
    end
  end
  
  def comp_bis?
  end
  
  def comp_energy
    [0, 0, 0, 1, 2, 3, 5, 7, 9, 12][@comp]
  end
  
  def comp_fib?
  end
  
  def crew
    # Includes commanding officers, so space/cost equations count them double
  end
  
  def crew_space_cost
    (commmanding_officers + crew) * 500_000
  end
  
  def crew_space_tons
    (commmanding_officers + crew) * 4
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
    @tons * 10_000 * [0, 12, 11, 10, 6, 7, 8, 5, 0.09, 0.075][@config]
  end
  
  def jump_cost
    jump_tons * 4_000_000
  end
  
  def jump_tons
    @jump > 0 ? @tons * (@jump + 1) / 100.0 : 0
  end
  
  def jump_with_tanks
    (100.0 * jump_tons / tons_with_tanks).to_i - 1
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
  
  def maneuver_with_tanks
    ((100.0 * maneuver_tons / tons_with_tanks + 1) / 3).to_i
  end
  
  def power_cost
    power_tons * 3_000_000
  end
  
  def power_tons
    @tons * @power * 3 / 100.0
  end
  
  def power_with_tanks
    (100.0 * power_tons / tons_with_tanks / 3).to_i
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
  
  def small_craft?
    @tons < 100 && @jump == 0
  end
  
  def tons_with_tanks
    @tons + @drop_tanks
  end
  
  def valid_fuel?
    # TODO: Fix to remove @jump_fuel
    # (@jump_fuel + @drop_tanks) >= (@tons + @drop_tanks) * @jump / 10.0
  end
  
  def self.read_usp(code)
    @usp_hash ||= {}
    @usp_hash[code] ||= self.usp_codes.index(code)
  end
  
  def self.usp_codes
    @usp_codes ||= usp_codes!
  end
  
  def self.usp_codes!
    usp_codes = ("0".."9").to_a + ("A".."Z").to_a
    usp_codes.delete("I")
    usp_codes.delete("O")
    usp_codes
  end
end

class Eurisko < Ship
  def initialize
    super("Ba-K952563-J41100-34003-0", "1     11  V", 5_550, 555, 11_100)
  end
end

class Wasp < Ship
  def initialize
    super("Il-A90ZZF2-J00000-00009-0", "          1", 0, 60, 1_000)
  end
end

class Bee < Ship
  def initialize
    super("FF-0906661-A30000-00001-0", "1         2", 0, 5.94, 99)
  end
end