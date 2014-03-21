require 'set'
require './lib/battery'

class Ship
  attr_accessor :armor, :comp, :config, :crew_code, :drop_tanks, :energy_weapons
  attr_accessor :energy_weapon_count, :fighters, :hits, :jump, :lasers
  attr_accessor :laser_count, :maneuver, :meson_gun, :meson_gun_count
  attr_accessor :meson_screen, :missiles, :missile_count, :nuc_damp, :options
  attr_accessor :particle_acc, :particle_acc, :particle_acc_count, :force_field
  attr_accessor :power,  :repulsors, :repulsor_count, :sand, :sand_count, :tons
    
  def initialize(usp, batteries, drop_tanks, fuel, tons, options={})
    # TODO: Auxillary bridge, frozen watch, scoops, troops
    @armor = Ship.read_usp(usp[11])
    @comp = usp[8]
    @config = Ship.read_usp(usp[4])
    @crew_code = Ship.read_usp(usp[9])
    @drop_tanks = drop_tanks
    @energy_weapons = Ship.read_usp(usp[19])
    @energy_weapon_count = Ship.read_usp(batteries[7])
    @figters = Ship.read_usp(usp[24])
    @fuel = fuel
    @hits = {}
    @jump = Ship.read_usp(usp[5])
    @lasers = Ship.read_usp(usp[18])
    @laser_count = Ship.read_usp(batteries[6])
    @maneuver = Ship.read_usp(usp[6])
    @meson_gun = Ship.read_usp(usp[21])
    @meson_gun_count = Ship.read_usp(batteries[9])
    @meson_screen = Ship.read_usp(usp[13])
    @missiles = Ship.read_usp(usp[22])
    @missile_count = Ship.read_usp(batteries[10])
    @nuc_damp = Ship.read_usp(usp[14])
    @particle_acc = Ship.read_usp(usp[20])
    @particle_acc_count = Ship.read_usp(batteries[8])
    @force_field = Ship.read_usp(usp[15])
    @options = options
    @power = Ship.read_usp(usp[7])
    @repulsors = Ship.read_usp(usp[16])
    @repulsor_count = Ship.read_usp(batteries[4])
    @sand = Ship.read_usp(usp[12])
    @sand_count = Ship.read_usp(batteries[0])
    @tons = tons
  end
  
  def armor_cost
    (300_000 + 100_000 * armor) * armor_tons
  end
  
  def armor_tons
    tons * (2 + 2 * armor)
  end
  
  def battery_count
    @energy_weapon_count + @laser_count + @meson_gun_count + @particle_acc_count + @missile_count + @sand_count
  end
  
  def bay_weapons
    # Assuming plasma guns and fusion guns can't be bay weapons
    subtotal = 0
    subtotal += @particle_acc_count if @particle_acc < 10
    subtotal += @meson_gun_count if @meson_gun < 10
    subtotal += @repulsor_count if @repulsors == 6
    subtotal += @missle_cont if @missiles > 6
    subtotal
  end
  
  def bridge_cost
    5_000 * @tons
  end
  
  def bridge_tons
    [20, @tons * 0.02].max
  end
  
  def comp_cost
    if comp_fib?
      [0, 3, 14, 27, 45, 68, 83, 100, 140, 200][comp_model] * 1_000_000
    elsif comp_bis?
      [0, 4, 18][comp_model] * 1_000_000
    else
      [0, 2, 9, 18, 30, 45, 55, 80, 110, 140][comp_model] * 1_000_000
    end
  end
  
  def comp_bis?
    @comp == 'R' || @comp == 'S'
  end
  
  def comp_energy
    [0, 0, 0, 1, 2, 3, 5, 7, 9, 12][comp_model]
  end
  
  def comp_fib?
    ('A'..'J').include?(@comp)
  end
  
  def comp_model
    @comp_model ||= comp_model!
  end
  
  def comp_model!
    if @comp == 'R'
      @comp_model = 1 
    elsif @comp == 'S'
      @comp_model = 2
    else
      @comp_model = Ship.read_usp(@comp) % 9
      @comp_model = 9 if @comp_model == 0
    end
    @comp_model
  end
  
  def comp_tons
    @comp < 6 ? base = @comp : base = @comp * 2 - 5
    comp_fib? ? base * 2 : base
  end
  
  def cost
    armor + comp_cost + crew_space_cost + drop_tank_cost + energy_weapons_cost +
      hull_cost + jump_cost + laser_cost + maneuver_cost + meson_gun_cost +
      meson_screen_cost + nuc_damp_cost + particle_acc_cost + power_cost +
      repulsor_cost + sand_cost + scoops_cost
  end
  
  def crew
    # Includes officers, so space/cost equations count them double
    if small_craft?
      return 2
    elsif tons <= 1000
      subtotal = 1 + battery_count
      subtotal += 2 + power_tons / 35 if tons >= 200
      return subtotal
    else
      if tons <= 20_000
        subtotal = 6
      else
        subtotal = 5 * (tons / 10_000)
      end
      subtotal += (jump_tons + maneuver_tons + power_tons).to_i / 100
      subtotal += (major_weapon_tons / 100 - 1) if major_weapon_tons > 0
      subtotal += battery_count
      subtotal += bay_weapons
      subtotal += screen_count * 4
      return subtotal
    end
  end
  
  def crew_space_cost
    (crew + sec_heads) * 500_000
  end
  
  def crew_space_tons
    (crew + sec_heads) * 4
  end
  
  def drop_tank_cost
    @drop_tanks > 0 ? 1_000 * (@drop_tanks + 10) : 0
  end
  
  def energy
    @tons * @power * 0.01
  end
  
  def energy_weapons_cost
    EnergyWeapon.new(@energy_weapons).cost * @energy_weapon_count
  end
  
  def energy_weapons_energy
    EnergyWeapon.new(@energy_weapons).energy * @energy_weapon_count
  end
  
  def energy_weapons_tons
    EnergyWeapon.new(@energy_weapons).tons * @energy_weapon_count
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
  
  def laser_cost
    Laser.new(@lasers, options[:laser_type]).cost * @laser_count
  end
  
  def laser_energy
    Laser.new(@lasers, options[:laser_type]).energy * @laser_count
  end
  
  def laser_tons
    Laser.new(@lasers, options[:laser_type]).tons * @laser_count
  end
  
  def major_weapon_tons
    if @meson_gun > 9
      return MesonGun.new(@meson_gun).tons
    elsif @particle_acc > 9
      return ParticleAccelerator.new(@particle_acc).tons
    else
      return 0
    end
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
  
  def meson_gun_cost
    MesonGun.new(@meson_gun).cost
  end
  
  def meson_gun_energy
    MesonGun.new(@meson_gun).energy
  end
  
  def meson_gun_tons
    MesonGun.new(@meson_gun).tons
  end
  
  def meson_screen_cost
    # Factors above 1 not allowed at TL 12
    @meson_screen > 0 ? 80_000 : 0
  end
  
  def meson_screen_energy
    # Factors above 1 not allowed at TL 12
    @meson_screen > 0 ? 0.2 * @tons / 100 : 0
  end
  
  def meson_screen_tons
    # Factors above 1 not allowed at TL 12
    @meson_screen > 0 ? 90 : 0
  end
  
  def missiles_cost
    Missiles.new(@missiles).cost * @missile_count
  end
  
  def missiles_tons
    Missiles.new(@missiles).tons * @missile_count
  end
  
  def nuc_damp_cost
    # Factors above 1 not allowed at TL 12
    @nuc_damp > 0 ? 50_000 : 0
  end
  
  def nuc_damp_energy
    # Factors above 1 not allowed at TL 12
    @nuc_damp > 0 ? 10 : 0
  end
  
  def nuc_dam_tons
    # Factors above 1 not allowed at TL 12
    @nuc_damp > 0 ? 50 : 0
  end
  
  def particle_acc_cost
    ParticleAccelerator.new(@particle_acc).cost * @particle_acc_count
  end
  
  def particle_acc_energy
    ParticleAccelerator.new(@particle_acc).energy * @particle_acc_count
  end
  
  def particle_acc_tons
    ParticleAccelerator.new(@particle_acc).tons * @particle_acc_count
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
  
  def repulsor_cost
    # 100-ton bay type only type available at TL 12
    @repulsors > 0 ? 10_000_000 * @repulsor_count : 0
  end
  
  def repulsor_energy
    # 100-ton bay type only type available at TL 12
    @repulsors > 0 ? 10 * @repulsor_count : 0
  end
  
  def repulsor_tons
    # 100-ton bay type only type available at TL 12
    @repulsors > 0 ? 100 * @repulsor_count : 0
  end

  def sand_cost
    SandCaster.new(sand).cost * sand_count
  end
  
  def sand_tons
    SandCaster.new(sand).tons * sand_count
  end
  
  def scoops_cost
    options[:scoops] ? @tons * 1_000 : 0
  end
  
  def screen_count
    subtotal = 0
    subtotal += 1 if @nuc_damp > 0
    subtotal += 1 if @meson_screen > 0
    subtotal += 1 if @force_field > 0
    subtotal
  end
  
  def sec_heads
    # May add rules for flight secion head and troops commander later
    tons > 1000 ? 3 : 0
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
    total_fuel = @fuel + @drop_tanks
    needed_fuel_percent = jump_with_tanks / 10.0 + power_with_tanks / 100.0
    total_fuel >= needed_fuel_percent * tons_with_tanks
  end
  
  def valid_screens?
    @meson_screen < 2 && @nuc_damp < 2 && @force_field == 0
  end
  
  def self.read_usp(code)
    @usp_hash ||= { ' ' => 0 }
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
    super("Il-A9066F2-J00000-00009-0", "          1", 0, 60, 1_000)
  end
end

class Bee < Ship
  def initialize
    super("FF-0906661-A30000-00001-0", "1         2", 0, 5.94, 99)
  end
end