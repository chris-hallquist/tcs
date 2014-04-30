require './lib/ship'

class Fleet
  attr_accessor :ship_classes, :ship_counts, :player, :ships 
  attr_accessor :battle_line, :reserve
  
  def initialize(ship_classes, ship_counts, player, is_dup=false)
    @ship_classes = ship_classes
    @ship_counts = ship_counts
    @player = player
    @ships = ships! unless is_dup
    player.fleet = self
  end
  
  def apply_damage
    ships.map! { |ship| ship.shadow }
    ships.each { |ship| ship.sync_battery_comps }
    ships.each { |ship| ship.shadow = ship.deep_dup }
    ships.select! { |ship| !ship.hits[:perm_disabled] }
  end
  
  def can_fire?
    ships.any? { |ship| ship.can_fire? }
  end
  
  def cost
    result = 0
    ship_classes.each_with_index do |ship_class, index|
      result += ship_class.cost * 0.21
      result += ship_class.cost * 0.8 * ship_counts[index]
    end
    result
  end
  
  def deep_dup
    new_fleet = Fleet.new(ship_classes, ship_counts, player, true)
    if battle_line && reserve
      new_fleet.battle_line = battle_line.map(&:deep_dup)
      new_fleet.reserve = reserve.map(&:deep_dup)
      new_fleet.ships = new_fleet.battle_line + new_fleet.reserve
    else
      new_fleet.ships = ships.map(&:deep_dup)
    end
    new_fleet
  end
  
  def form_lines
    @battle_line = []
    @reserve = []
    ships.each do |ship|
      if player.assign_to_battle_line?(ship) 
        @battle_line << ship 
      else
        @reserve << ship
      end
    end
  end
  
  def least_agility
    min = ships[0].agility_with_tanks
    ships.each do |ship|
      min = [min, ship.agility_with_tanks].min
    end
    min
  end
  
  def pilots
    result = 0
    ships.each do |ship|
      if ship.tons < 500
        result += 1
      elsif ship.tons <= 20_000
        result += 2
      else
        result += 3
      end
    end
    result
  end
  
  def repair
    # Ships in reserve are repaired automatically,
    # as there is no downside to doing so
    reserve.each do |ship|
      ship.repair(player)
    end
  end
  
  def reset_fired_counts
    ships.each do |ship|
      ship.batteries.each_value do |obj|
        obj.fired_count = 0
      end
    end
  end
  
  def ships!
    result = []
    @ship_classes.each_with_index do |ship_class, i|
      ship_class.fleet = self
      ship_class.shadow.fleet = self
      j = 0
      ship_counts[i].times { result << ship_class.deep_dup }
    end
    result
  end
  
  def size
    ships.size
  end
  
  def tcs_can_refuel?
    total_fuel = 0
    total_streamlined_fuel = 0
    ships.each do |ship|
      total_fuel += ship.total_fuel
      total_streamlined_fuel += ship.total_fuel if ship.streamlined?
    end
    total_streamlined_fuel.to_f / total_fuel >= 0.1
  end
  
  def tcs_valid?
    return false unless ship_classes.all? do |ship| 
      ship.valid? && ship.maneuver_with_tanks > 0 
    end 
    pilots <= 200 && cost <= 1_000_000_000_000 && tcs_valid_jump? &&
      tcs_can_refuel?
  end
  
  def tcs_valid_jump?
    carried_craft = {}
    ship_classes.each_with_index do |ship_class, i|
      vehicles = ship_class.options[:vehicles] || []
      vehicles.each do |vehicle|
        carried_craft[vehicle.class] ||= 0
        carried_craft[vehicle.class] += ship_counts[i]
      end
    end
    ship_classes.each_index.all? do |i|
      ship_class = ship_classes[i]
      ship_class.jump_with_tanks > 2 || (carried_craft[ship_class.class] &&
       carried_craft[ship_class.class] >= ship_counts[i])
    end
  end
end

class Lenat < Fleet
  def initialize(player)
    super(
      [Garter.new, Cisor.new, Queller.new, Eurisko.new, Wasp.new, Bee.new],
      [4, 4, 3, 75, 7, 3],
      player
    )
  end
end

class OneEurisko < Fleet
  def initialize(player)
    super([Eurisko.new], [1], player)
  end
end

class OneQueller < Fleet
  def initialize(player)
    super([Queller.new], [1], player)
  end
end

class OneCisor < Fleet
  def initialize(player)
    super([Cisor.new], [1], player)
  end
end