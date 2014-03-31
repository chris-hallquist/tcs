class Fleet
  attr_accessor :ship_classes, :ship_counts, :player, :ships
  
  def initialize(ships_classes, ship_counts, player, is_dup=false)
    @ship_classes = ship_classes
    @ship_counts = ship_counts
    @player = player
    @ships = ships! unless is_dup
  end
  
  def cost
    result = 0
    ship_classes.each_with_index do |class, index|
      result += class.cost * 0.21
      result += class.cost * 0.8 * ship_counts[index]
    end
    result
  end
  
  def deep_dup
    new_fleet = Fleet.new(ship_classes, ship_counts, player, true)
    new_fleet.ships = []
    ships.each do |ship|
      new_fleet.ships << ship.deep_dup
    end
    new_fleet
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
  
  def ships!
    result = []
    ship_classes.each_with_index do |class, index|
      result = result + [class.deep_dup] * ship_counts[index]
    end
    result
  end
  
  def TCS_valid?
    ships.all? { |ship| ship.valid? && ship.jump_with_tanks > 2 } && 
      pilots <= 200 && cost <= 1_000_000_000_000
  end
end