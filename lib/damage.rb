require './lib/ship'
require './lib/TCS'

module Damage
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
  
  def self.bridge_destroyed(ship)
    # Critical only

    # Will need to be modified to handle 
    # auxilliary bridges, and ships with no bridge
    ship.hits[:bridge_destroyed] = true
  end

  def self.computer(ship, n, radiation=false)
    # Can be repaired
    return if radiation && ship.comp_fib?
    n = ship.comp_model if ship.comp_model < n
    ship.comp_model -= n
    ship.hits[:computer] ||= []
    ship.hits[:computer] << n
  end
  
  def self.computer_destroyed(ship, n)
    # Critical only
    ship.hits[:computer] = []
    ship.comp_mode = 0
  end
  
  def self.crew(ship, n)
    # Can be replaced by frozen watch
    ship.hits[:crew] ||= 0
    ship.hits[:crew] += n
    ship.hits[:perm_disabled] = true if ship.hits[:crew] > 1 ||
     !ship.options[:frozen_watch] 
  end
  
  def self.critical(ship, firing_player)
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
      one_screen_disabled(ship, firing_player)
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
    ship.options[:frozen_watch] = false
  end
  
  def self.fuel(ship, n)
    ship.hits[:fuel] ||= 0
    ship.hits[:fuel] += [10, ship.fuel * n / 100.0].max
    ship.hits[:perm_disabled] = true if ship.hits[:fuel] >= ship.fuel 
  end
  
  def self.fuel_tanks_shattered(ship)
    ship.hits[:perm_disabled] = true
  end
  
  def self.hangars_boat_deck_destroyed(ship)
    # Critical only
    # Doesn't matter, if ships launched before combat
  end
  
  def self.interior_explosion(ship, firing_player, mod=0)
    case TCS.roll + mod
    when 2..4
      Damage.critical(ship, firing_player)
    when 5
      Damage.fuel_tanks_shattered(ship)
    when 6
      Damage.computer(ship, 2)
    when 7
      Damage.screen(ship, firing_player, 3)
    when 8
      Damage.jump(ship, 2)
    when 9
      Damage.power(ship, 2)
    when 10
      Damage.crew(ship, 1)
    when 11
      Damage.computer(ship, 1)
    when 12
      Damage.screen(ship, firing_player, 2)
    when 13
      Damage.jump(ship, 1)
    when 14
      Damage.power(ship, 1)
    when 15
      Damage.computer(ship, 1)
    when 16
      Damage.screen(ship, firing_player, 1)
    when 17
      Damage.jump(ship, 1)
    when 18
      Damage.power(ship, 1)
    when 19
      Damage.screen(ship, firing_player, 1)
    when 20
      Damage.jump(ship, 1)
    when 21
      Damage.power(ship, 1)
    end
  end
  
  def self.jump(ship, n)
    # Can be repaired
    # Repairability will be ignored due to irrelevance to TCS
    # In fact, this whole thing is irrelevant to TCS
  end
  
  def self.jump_drive_disabled(ship)
    # Critical only
    # Similarly irrelevant
  end
  
  def self.maneuver(ship, n)
    # Can be repaired
    n = ship.maneuver if ship.maneuver < n
    ship.maneuver -= n
    ship.hits[:maneuver] ||= []
    ship.hits[:maneuver] << n
  end
  
  def self.maneuver_drive_disabled(ship)
    ship.maneuver = 0
    ship.hits[:maneuver] = []
  end
  
  def self.one_screen_disabled(ship, firing_player)
    # Critical only
    if ship.meson_screen = 0
      ship.nuc_damp = 0
    elsif ship.nuc_damp = 0
      ship.meson_screen = 0
    else
      case firing_player.assign_damage(["Meson Screen", "Nuclear Damper"])
      when 0
        ship.meson_screen = 0
      when 1
        ship.nuc_damp = 0
      end
    end
  end
  
  def self.power(ship, n)
    # Can be repaired
    n = ship.power if ship.power < n
    ship.power -= n
    ship.hits[:power] ||= []
    ship.hits[:power] << n
  end
  
  def self.power_plant_disabled(ship)
    # Critical only
    ship.hits[:power] = []
    ship.power = 0
  end
  
  def self.radiation(ship, firing_player, mod=0)
    case TCS.roll + mod
    when 2
      critical(ship, firing_player)
    when 3
      crew(ship, 1)
    when 4
      computer(ship, 4, true)
    when 5
      crew(ship, 1)
    when 6
      computer(ship, 3, true)
    when 7
      crew(ship, 1)
    when 8..9
      computer(ship, 2, true)
    when 10
      weapon(ship, firing_player, 4)
    when 11
      computer(ship, 2, true)
    when 12
      weapon(ship, firing_player, 3)
    when 13
      computer(ship, 1, true)
    when 14
      weapon(ship, firing_player, 2)
    when 15
      computer(ship, 1, true)
    when 16
      weapon(ship, firing_player, 2)
    when 17..21
      weapon(ship, firing_player, 1)
    end
  end
  
  def self.screen(ship, firing_player, n)
    # Can be repaired
    if ship.meson_screen = 0
      ship.hits[:nuc_damp] = [1] if ship.nuc_damp > 0
      ship.nuc_damp = 0
    elsif ship.nuc_damp = 0
      ship.hits[:meson_screen] = [1] if ship.meson_screen > 0
      ship.meson_screen = 0
      sh
    else
      case firing_player.assign_damage(["Meson Screen", "Nuclear Damper"])
      when 0
        ship.hits[:meson_screen] = [1] if ship.meson_screen > 0
        ship.meson_screen = 0
      when 1
        ship.hits[:nuc_damp] = [1] if ship.nuc_damp > 0
        ship.nuc_damp = 0
      end
    end
  end
  
  def self.ship_vaporized(ship)
    # Critical only
    ship.hits[:perm_disabled] = true
  end
  
  def self.surface_explosion(ship, firing_player, mod=0)
    case TCS.roll + mod
    when 2
      critical(ship, firing_player)
    when 3..5
      interior_explosion(ship, firing_player)
    when 6
      maneuver(ship, 2)
    when 7
      fuel(ship, 3)
    when 8
      weapon(ship, firing_player, 3)
    when 9
      maneuver(ship, 1)
    when 10
      fuel(ship, 2)
    when 11
      weapon(ship, firing_player, 2)
    when 12
      maneuver(ship, 1)
    when 13
      fuel(ship, 1)
    when 14..15
      weapon(ship, firing_player, 1)
    when 16
      fuel(ship, 1)
    when 17..18
      weapon(ship, firing_player, 1)
    when 19
      fuel(ship, 1)
    when 20..21
      weapon(ship, firing_player, 1)
    end
  end
  
  def self.spinal_mount_fire_control_out(ship)
    # Critical only
    if rand(2) == 0
      spinal_mount = ship.spinal_mount
      if spinal_mount
        ship.batteries[spinal_mount].factor = 0
        ship.hits[spinal_mount] = []
      end
      
      ship.hits[:spinal_mount_out] = true
      ship.hits[:perm_disabled] = true if ship.hits[:fire_control_out] ||
       !ship.has_non_spinal?
    else
      ship.batteries.each do |sym, obj|
        unless sym == ship.spinal_mount
          obj.factor = 0
          ship.hits[sym] = []
        end
      end
  
      ship.hits[:fire_control_out] = true
      ship.hits[:perm_disabled] = true if ship.hits[:spinal_mount_out] || 
       !ship.spinal_mount
    end
  end
  
  def self.weapon(ship, firing_player, n)
    # Can be repaired
    return if ship.batteries_remaining.empty?
    valid_targets = ship.batteries_least_damaged.keys
    target_key = valid_targets[firing_player.assign_damage(valid_targets)]
    target = ship.batteries[target_key]
    if target.uniq?
      n = target.factor if target.factor < n
      target.factor -= n
      ship.hits[target_key] ||= []
      ship.hits[target_key] << n
    else
      target.count -= 1
      ship.hits[target_key] ||= []
      ship.hits[target_key] << 1
    end
  end     
end