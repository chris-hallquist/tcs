require 'ship'
require 'TCS'

class Damage
  def self.bridge_destroyed(ship)
    # Critical only
    # Handle effects elsewhere
    ship.hits[:bridge_destroyed] = true
  end

  def self.computer(ship, n)
    # Can be repaired
    n = ship.computer_model if ship.computer_model < n
    ship.computer_mode -= n
    ship.hits[:computer] ||= []
    ship.hits[:computer] << n
  end
  
  def self.computer_destroyed(ship, n)
    # Critical only
  end
  
  def self.crew(ship, n)
    # Can be replaced by frozen watch
    ship.hits[:crew] ||= 0
    ship.hits[:crew] += 1
  end
  
  def self.critical(ship)
    ship.armor -= 1 if ship.armor > 1
    case TCS.roll
    when 2
      ship_vaporized(ship)
    when 3
      bridge_destroyed(ship)
    when 4
      computer_destroyed(ship)
    when 5
      maneuver_drive_disabled(ship)
    when 6
      one_screen_disabled(ship)
    when 7
      jump_drive_disabled(ship)
    when 8
      hangars_boat_deck_destroyed(ship)
    when 9
      power_plant_disabled(ship)
    when 10
      crew(ship, 1)
    when 11
      spinal_mount_fire_control_out(ship)
    when 12
      frozen_watch_ships_troops_dead(ship)
    end
  end
  
  def self.frozen_watch_ships_troops_dead(ship)
    # Critical only
  end
  
  def self.fuel(ship, n)
  end
  
  def self.fuel_tanks_shattered(ship)
  end
  
  def self.hangars_boat_deck_destroyed(ship)
    # Critical only
  end
  
  def self.interior_explosion(ship, mod=0)
  end
  
  def self.jump(ship, n)
    # Can be repaired
    # Repairability will be ignored due to irrelevance to TCS
  end
  
  def self.jump_drive_disabled(ship)
    #Critical only
  end
  
  def self.maneuver(ship, n)
  end
  
  def self.one_screen_disabled(ship)
    # Critical only
  end
  
  def self.power(ship, n)
    # Can be repaired
  end
  
  def self.power_plant_disabled(ship)
    # Critical only
  end
  
  def self.radiation(ship, mod=0)
  end
  
  def self.screen(ship, n)
    # Can be repaired
  end
  
  def self.ship_vaporized(ship)
    # Critical only
  end
  
  def self.surface_explosion(ship, mod=0)
  end
  
  def self.spinal_mount_fire_control_out(ship)
    # Critical only
  end
  
  def self.weapon(ship, n)
    # Can be repaired
  end     
end