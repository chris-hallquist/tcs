require 'set'
require './lib/battery'

class Ship
  attr_accessor :armor, :comp, :config, :crew_code, :drop_tanks, :energy_weapon
  attr_accessor :energy_weapon_count, :fighters, :fuel, :hits, :jump, :laser
  attr_accessor :laser_count, :maneuver, :meson_gun, :meson_gun_count
  attr_accessor :meson_screen, :missile, :missile_count, :nuc_damp, :options
  attr_accessor :particle_acc, :particle_acc, :particle_acc_count, :force_field
  attr_accessor :power,  :repulsor, :repulsor_count, :sand, :sand_count, :tons
  attr_writer :batteries, :comp_model
  attr_accessor :fleet, :shadow
  
  REPAIRABLE = [
    :computer,
    :energy_weapon,
    :laser,
    :maneuver,
    :meson_gun,
    :meson_screen,
    :missile,
    :nuc_damp,
    :particle_acc,
    :power,
    :repulsor,
    :sand
    ]

  def initialize(usp, batteries, drop_tanks, fuel, tons, options={})
    # TODO: Auxillary bridge, frozen watch, scoops, troops
    @armor = Ship.read_usp(usp[11])
    @comp = usp[8]
    @config = Ship.read_usp(usp[4])
    @crew_code = Ship.read_usp(usp[9])
    @drop_tanks = drop_tanks
    @energy_weapon = Ship.read_usp(usp[19])
    @energy_weapon_count = Ship.read_usp(batteries[7])
    @figters = Ship.read_usp(usp[24])
    @fuel = fuel
    @hits = {}
    @jump = Ship.read_usp(usp[5])
    @laser = Ship.read_usp(usp[18])
    @laser_count = Ship.read_usp(batteries[6])
    @maneuver = Ship.read_usp(usp[6])
    @meson_gun = Ship.read_usp(usp[21])
    @meson_gun_count = Ship.read_usp(batteries[9])
    @meson_screen = Ship.read_usp(usp[13])
    @missile = Ship.read_usp(usp[22])
    @missile_count = Ship.read_usp(batteries[10])
    @nuc_damp = Ship.read_usp(usp[14])
    @particle_acc = Ship.read_usp(usp[20])
    @particle_acc_count = Ship.read_usp(batteries[8])
    @force_field = Ship.read_usp(usp[15])
    @options = options
    @power = Ship.read_usp(usp[7])
    @repulsor = Ship.read_usp(usp[16])
    @repulsor_count = Ship.read_usp(batteries[4])
    @sand = Ship.read_usp(usp[12])
    @sand_count = Ship.read_usp(batteries[0])
    @tons = tons
    batteries
    has_non_spinal?
    spinal_mount
    @shadow = self.deep_dup
  end
  
  def agility
    [((energy - energy_used) / (0.01 * tons)).to_i, maneuver].min
  end
  
  def agility_with_tanks
    if power == 0
      0
    elsif hits[:power] 
      [agility_with_tanks! - hits[:power].length, 0].max
    else
      agility_with_tanks!
    end
  end
  
  def agility_with_tanks!
    [((energy_with_tanks - energy_used) / (0.01 * tons)).to_i,
       maneuver_with_tanks].min
  end
  
  def armor_cost
    (300_000 + 100_000 * armor_purchased) * armor_tons
  end
  
  def armor_purchased
    if config == 8
      free_armor = 3
    elsif config == 9
      free_armor = 6
    else
      free_armor = 0
    end
    armor - free_armor
  end
  
  def armor_tons
    tons * (2 + 2 * armor_purchased) / 100.0
  end
  
  def batteries
    @batteries ||= batteries!
  end
  
  def batteries!
    @batteries = {}
    if energy_weapon > 0 && energy_weapon_count > 0
      args = [energy_weapon, energy_weapon_count, effective_comp]
      args << options[:energy_weapon_type] if options[:energy_weapon_type]
      @batteries[:energy_weapon] = EnergyWeapon.new(*args)
    end
    if laser > 0 && laser_count > 0
      args = [laser, laser_count, effective_comp]
      args << options[:laser_type] if options[:laser_type]
      @batteries[:laser] = Laser.new(*args)
    end
    if meson_gun > 0 && meson_gun_count > 0
      @batteries[:meson_gun] = MesonGun.new(
        meson_gun, 
        meson_gun_count, 
        effective_comp
      )
    end
    if missile > 0 && missile_count > 0
      args = [missile, missile_count, effective_comp]
      args << options[:missile_type] if options[:missile_type]
      @batteries[:missile] = Missile.new(*args)
    end
    if particle_acc > 0 && particle_acc_count > 0
      @batteries[:particle_acc] = ParticleAccelerator.new(
        particle_acc, 
        particle_acc_count,
        effective_comp
      )
    end
    if repulsor > 0 && repulsor_count > 0
      @batteries[:repulsor] = Repulsor.new(
        repulsor, 
        repulsor_count, 
        effective_comp
      )
    end
    if sand > 0 && sand_count > 0
      @batteries[:sand] = SandCaster.new(sand, sand_count, effective_comp)
    end
    @batteries
  end
  
  def batteries_least_damaged
    return batteries_undamaged unless batteries_undamaged.empty?
    min = batteries_remaining.map { |sym, obj| hits[sym].length }.min
    batteries_remaining.select { |sym, obj| hits[sym].length == min }
  end
  
  def batteries_remaining
    batteries.select do |sym, obj|
      obj.factor > 0 && obj.count > 0
    end
  end
  
  def batteries_undamaged
    batteries.select do |sym, obj|
      !hits[sym] || hits[sym].empty?
    end
  end
  
  def battery_count
    @energy_weapon_count + @laser_count + @meson_gun_count + @particle_acc_count + @missile_count + @sand_count
  end
  
  def bay_weapons
    # Assuming plasma guns and fusion guns can't be bay weapons
    subtotal = 0
    subtotal += @particle_acc_count if @particle_acc < 10
    subtotal += @meson_gun_count if @meson_gun < 10
    subtotal += @repulsor_count if @repulsor == 6
    subtotal += @missile_count if @missile > 6
    subtotal
  end
  
  def bridge_cost
    return 0 if options[:no_bridge]
    5_000 * @tons
  end
  
  def bridge_tons
    return 0 if options[:no_bridge]
    [20, @tons * 0.02].max
  end
  
  def can_fire?
    return false if self.hits[:crew] && self.hits[:crew] > 0
    return false if self.hits[:perm_disabled]
    batteries.each_value do |battery|
      return true if battery.factor > 0 && battery.count > 0
    end
    false
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
    if comp == 'R'
      @comp_model = 1 
    elsif comp == 'S'
      @comp_model = 2
    else
      @comp_model = Ship.read_usp(@comp) % 9
      @comp_model = 9 if comp_model == 0
    end
    @comp_model
  end
  
  def comp_tons
    comp_model < 6 ? base = comp_model : base = comp_model * 2 - 5
    comp_fib? ? base * 2 : base
  end
  
  def cost
    armor_cost + bridge_cost + comp_cost + crew_space_cost + drop_tank_cost +
     energy_weapon_cost + frozen_cost + hull_cost + jump_cost + laser_cost +
     maneuver_cost + meson_gun_cost + meson_screen_cost + missile_cost +
     nuc_damp_cost + particle_acc_cost + power_cost + repulsor_cost + 
     sand_cost + scoops_cost + vehicle_cost
  end
  
  def cost_summary
    # For debugging
    puts "The armor costs #{armor_cost / 1_000_000} MCr"
    puts "The bridge costs #{bridge_cost / 1_000_000} MCr"
    puts "The computer costs #{comp_cost / 1_000_000} MCr"
    puts "The crew quarters cost #{crew_space_cost / 1_000_000} MCr"
    puts "The drop tanks cost #{drop_tank_cost / 1_000_000} MCr"
    puts "The energy weapons cost #{energy_weapon_cost / 1_000_000} MCr"
    puts "The frozen watch costs #{frozen_cost / 1_000_000} MCr"
    puts "The hull costs #{hull_cost / 1_000_000} MCr"
    puts "The jump drive costs #{jump_cost / 1_000_000} MCr"
    puts "The laser cost #{laser_cost / 1_000_000} MCr"
    puts "The maneuver drive costs #{maneuver_cost / 1_000_000} MCr"
    puts "The meson gun costs #{meson_gun_cost / 1_000_000} MCr"
    puts "The meson screen costs #{meson_screen_cost / 1_000_000} MCr"
    puts "The missile cost #{missile_cost / 1_000_000} MCr"
    puts "The nuclear damper costs #{nuc_damp_cost / 1_000_000} MCr"
    puts "The particle accelerator costs #{particle_acc_cost / 1_000_000} MCr"
    puts "The power plant costs #{power_cost / 1_000_000} MCr"
    puts "The repulsor costs #{repulsor_cost / 1_000_000} MCr"
    puts "The sand-caster costs #{sand_cost / 1_000_000} MCr"
    puts "The space for vehicles costs #{vehicle_cost / 1_000_000} MCr"
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
  
  def deep_dup
    new_ship = self.dup
    
    new_ship.hits = {}
    hits.each do |key, value|
      new_ship.hits[key] = (value.class == Array ? value.dup : value)
    end
    
    new_ship.batteries = {}
    batteries.each do |sym, obj|
      new_ship.batteries[sym] = obj.dup
    end
        
    new_ship
  end
  
  def drop_tank_cost
    @drop_tanks > 0 ? 1_000 * (@drop_tanks + 10) : 0
  end
  
  def effective_comp
    hits[:bridge_destroyed] ? comp_model / 2 : comp_model
  end
  
  def energy
    @tons * @power * 0.01
  end
  
  def energy_with_tanks
    tons_with_tanks * power_with_tanks * 0.01
  end
  
  def energy_used
    comp_energy + energy_weapon_energy + laser_energy + meson_gun_energy +
     meson_screen_energy + nuc_damp_energy + particle_acc_energy +
     repulsor_energy
  end
  
  def energy_weapon_cost
    batteries[:energy_weapon] ? batteries[:energy_weapon].cost : 0
  end
  
  def energy_weapon_energy
    batteries[:energy_weapon] ? batteries[:energy_weapon].energy : 0
  end
  
  def energy_weapon_tons
    batteries[:energy_weapon] ? batteries[:energy_weapon].tons : 0
  end
  
  def expose_to_fire(firing_fleet, range)
    firing_player = firing_fleet.player
    batteries = firing_player.assign_batteries(firing_fleet, self)
    hits = batteries.select do |battery| 
      battery.fired_count += 1
      battery.fired_count <= battery.count && battery.hit?(self, range)
    end
    defenses = fleet.player.assign_defenses(self, hits)
    hits.each_with_index do |hit, i|
      if hit.defenses_penetrated?(self, defenses[i])
        hit.roll_damage(self, firing_player)
      end 
    end
  end
  
  def frozen_cost
    options[:frozen_watch] ? (crew / 2.0).ceil * 50_000 : 0
  end
  
  def frozen_tons
    options[:frozen_watch] ? (crew / 2.0).ceil * 0.5 : 0
  end

  def has_non_spinal?
    @has_non_spinal = has_non_spinal! unless defined? @has_non_spinal
    @has_non_spinal
  end

  def has_non_spinal!
    if laser > 0 || energy_weapon > 0 || missile > 0 || 
      (spinal_mount != :particle_acc && particle_acc > 0)
      return true
    else
      return false
    end
  end
  
  def hull_cost
    @tons * 10_000 * [0, 12, 11, 10, 6, 7, 8, 5, 0.09, 0.075][@config]
  end
  
  def hull_waste_tons
    if config == 8
      return tons * 0.20
    elsif config == 9
      return tons * 0.35
    else
      return 0
    end
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
    batteries[:laser] ? batteries[:laser].cost : 0
  end
  
  def laser_energy
    batteries[:laser] ? batteries[:laser].energy : 0
  end
  
  def laser_tons
    batteries[:laser] ? batteries[:laser].tons : 0
  end
  
  def major_weapon_tons
    if @meson_gun > 9
      return meson_gun_tons
    elsif @particle_acc > 9
      return particle_acc_tons
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
    batteries[:meson_gun] ? batteries[:meson_gun].cost : 0
  end
  
  def meson_gun_energy
    batteries[:meson_gun] ? batteries[:meson_gun].energy : 0
  end
  
  def meson_gun_tons
    batteries[:meson_gun] ? batteries[:meson_gun].tons : 0
  end
  
  def meson_screen_cost
    # Factors above 1 not allowed at TL 12
    @meson_screen > 0 ? 80_000_000 : 0
  end
  
  def meson_screen_energy
    # Factors above 1 not allowed at TL 12
    @meson_screen > 0 ? 0.2 * @tons / 100 : 0
  end
  
  def meson_screen_tons
    # Factors above 1 not allowed at TL 12
    @meson_screen > 0 ? 90 : 0
  end
  
  def missile_cost
    batteries[:missile] ? batteries[:missile].cost : 0
  end
  
  def missile_tons
    batteries[:missile] ? batteries[:missile].tons : 0
  end
  
  def nuc_damp_cost
    # Factors above 1 not allowed at TL 12
    @nuc_damp > 0 ? 50_000_000 : 0
  end
  
  def nuc_damp_energy
    # Factors above 1 not allowed at TL 12
    @nuc_damp > 0 ? 10 : 0
  end
  
  def nuc_damp_tons
    # Factors above 1 not allowed at TL 12
    @nuc_damp > 0 ? 50 : 0
  end
  
  def particle_acc_cost
    batteries[:particle_acc] ? batteries[:particle_acc].cost : 0
  end
  
  def particle_acc_energy
    batteries[:particle_acc] ? batteries[:particle_acc].energy : 0
  end
  
  def particle_acc_tons
    batteries[:particle_acc] ? batteries[:particle_acc].tons : 0
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
  
  def repair(owner)
    if hits[:reviving_frozen]
      hits[:reviving_frozen] = false
      options[:frozen_watch] = false
      hits[:crew] -= 1
    elsif 
      hits[:crew] && hits[:crew] > 0
      hits[:reviving_frozen] = true
    else
      choices = hits.keys.select do |sym|
        REPAIRABLE.include?(sym) && hits[sym].length > 0
      end
      choice = choices[owner.select_repair(choices)]
      n = hits[choice].sort!.pop
      if batteries[choice] 
        if batteries[choice].uniq?
          batteries[choice].factor 
        else
          batteries[choice].count += n
        end
      elsif choice == :computer
        self.comp_model += n
      else
        self.send("#{choice}=", self.send(choice) + n)
      end
    end
  end
  
  def repulsor_cost
    # 100-ton bay type only type available at TL 12
    @repulsor > 0 ? 10_000_000 * @repulsor_count : 0
  end
  
  def repulsor_energy
    # 100-ton bay type only type available at TL 12
    @repulsor > 0 ? 10 * @repulsor_count : 0
  end
  
  def repulsor_tons
    # 100-ton bay type only type available at TL 12
    @repulsor > 0 ? 100 * @repulsor_count : 0
  end

  def sand_cost
    batteries[:sand] ? batteries[:sand].cost : 0
  end
  
  def sand_tons
    batteries[:sand] ? batteries[:sand].tons : 0
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
  
  def spinal_mount
    @spinal_mount = spinal_mount! unless defined? @spinal_mount
    @spinal_mount
  end
  
  def spinal_mount!
    return :meson_gun if meson_gun > 9
    return :particle_acc if particle_acc > 9
    nil
  end
  
  def sync_battery_comps
    batteries.each_value do |battery|
      battery.comp = effective_comp
    end
  end
  
  def tonnage_code
    @tonnage_code ||= tonnage_code!
  end
  
  def tonnage_code!
    if tons < 1_000
      return tons.to_i / 100
    elsif tons < 10_000
      return tons.to_i / 1_000 + 9
    elsif tons < 60_000
      return tons.to_i / 10_000 + 18
    elsif tons < 75_000
      return 23
    elsif tons < 100_000
      return 24
    elsif tons < 600_000
      return tons.to_i / 100_000 + 24
    elsif tons < 700_000
      return 29
    elsif tons < 900_000
      return 30
    elsif tons < 1_000_000
      return 31
    else
      return 32
    end
  end
  
  def tons_used
    armor_tons + bridge_tons + comp_tons + crew_space_tons + 
     energy_weapon_tons + frozen_tons + fuel + hull_waste_tons + jump_tons +
     laser_tons + maneuver_tons + meson_gun_tons + meson_screen_tons +
     missile_tons + nuc_damp_tons + particle_acc_tons + power_tons + 
     repulsor_tons + sand_tons + vehicle_tons
  end
  
  def tons_used_summary
    # For debugging
    puts "#{armor_tons} tons are taken up by armor"
    puts "#{bridge_tons} tons are taken up by the bridge"
    puts "#{comp_tons} tons are taken up by the computer"
    puts "#{crew_space_tons} tons are taken up by space for the crew"
    puts "#{energy_weapon_tons} tons are taken up by energy weapons"
    puts "#{fuel} tons are taken up by fuel"
    puts "#{frozen_tons} tons are taken up by the frozen watch"
    puts "#{hull_waste_tons} tons are taken up by hull waste space"
    puts "#{jump_tons} tons are taken up by the jump drive"
    puts "#{laser_tons} tons are taken up by lasers"
    puts "#{maneuver_tons} tons are taken up by the maneuver_drive"
    puts "#{meson_gun_tons} tons are taken up by the meson gun"
    puts "#{meson_screen_tons} tons are taken up by the meson screen"
    puts "#{missile_tons} tons are taken up by missiles"
    puts "#{nuc_damp_tons} tons are taken up by the nuclear damper"
    puts "#{particle_acc_tons} tons are taken up by particle accelerators"
    puts "#{power_tons} tons are taken up by the power plant"
    puts "#{repulsor_tons} tons are taken up by repulsors"
    puts "#{sand_tons} tons are taken up by sand-casters"
    puts "#{vehicle_tons} tons are taken up by vehicles"
  end
  
  def tons_with_tanks
    @tons + @drop_tanks
  end
  
  def valid?
    valid_active_def? && valid_bridge? && valid_comp? && valid_energy? &&
      valid_fuel? && valid_major_weapon? && valid_screens? && valid_tons? &&
      valid_weapons_tech?
  end
  
  def valid_active_def?
    [0, 6].include?(repulsor) && ([0] + (3..9).to_a).include?(sand)
  end
  
  def valid_bridge?
    !options[:no_bridge] || tons < 100
  end
  
  def valid_comp?
    comp_model < 7 && ((!comp_fib? && !comp_bis?) || tons >=100)
  end
  
  def valid_energy?
    energy - energy_used >= 0
  end
  
  def valid_fuel?
    fuel >= tons * power * 0.01 && valid_jump_fuel?
  end
  
  def valid_jump_fuel?
    total_fuel = @fuel + @drop_tanks
    needed_fuel_percent = jump_with_tanks / 10.0 + power_with_tanks / 100.0
    total_fuel >= needed_fuel_percent * tons_with_tanks
  end
  
  def valid_major_weapon?
    !((meson_gun > 9 && (particle_acc > 9 || meson_gun_count > 1)) ||
     (particle_acc > 9 && particle_acc_count > 1))
  end
  
  def valid_screens?
    @meson_screen < 2 && @nuc_damp < 2 && @force_field == 0
  end
  
  def valid_tons?
    tons_used <= tons
  end
  
  def valid_weapons_tech?
    [0, 4, 8, 14, 20, 24].include?(particle_acc) && 
      [0, 12, 13, 19].include?(meson_gun) && 
      (missile < 7 || [8, 9].include?(missile)) && 
      laser < 9 && energy_weapon < 9
  end
  
  def vehicle_cost
    vehicle_tons * 2_000
  end
  
  def vehicle_tons
    result = 0
    if options[:vehicles]
      options[:vehicles].each do |vehicle|
        if vehicle.tons < 100 
          result += vehicle.tons * 1.3 
        else
          result += vehicle.tons * 1.1
        end
      end
    end
    result
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
    super("BA-K952563-J41100-34003-0", "1     11  V", 5_550, 555, 11_100)
  end
end

class Wasp < Ship
  def initialize
    super("Il-A9066F2-J00000-00009-0", "          1", 0, 60, 1_000)
  end
end

class Bee < Ship
  def initialize
    super("FF-0906661-A30000-00001-0", "1         2", 0, 5.94, 99, { no_bridge: true })
  end
end

class Garter < Ship
  def initialize
    super("TB-K1567F3-B41106-34009-1", "C   1 EE  7", 6_000, 840, 12_000, { frozen_watch: true, vehicles: [Wasp.new] })
  end
end

class Cisor < Ship
  def initialize
    super("BD-K9525F3-E41100-340C5-0", "1     11 1U", 9_990, 999, 19_980, { frozen_watch: true })
  end
end

class Queller < Ship
  def initialize
    super("BH-K1526F3-B41106-34Q02-1", "Z   1 NN1 N", 9_800, 1_176, 19_600, { frozen_watch: true, vehicles: [Bee.new, Wasp.new] })
  end
end

class Hornet < Ship
  def initialize
    super("Il-A9066F2-900000-00009-0", "          1", 0, 60, 1_000)
  end
end