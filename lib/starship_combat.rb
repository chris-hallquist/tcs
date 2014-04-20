require './lib/fleet'

class StarshipCombat
  attr_accessor :fleet1, :fleet2
  
  def initialize(fleet1, fleet2)
    @fleet1, @fleet2 = fleet1, fleet2
    player1.enemy, player2.enemy = fleet2, fleet1
    @round = 1
  end
  
  def both_fleets(method, *args)
    [fleet1, fleet2].each { |fleet| fleet.send(method, *args) }
  end
  
  def both_players(method, *args)
    [player1, player2].each { |player| player.send(method, *args) }
  end
  
  def breakthrough_step
    fleet1_can_fire = fleet1.battle_line.any? { |ship| ship.can_fire? }
    fleet2_can_fire = fleet2.battle_line.any? { |ship| ship.can_fire? }
    combat_step(:fleet1) if fleet1_can_fire && !fleet2_can_fire
    combat_step(:fleet2) if fleet2_can_fire && !fleet1_can_fire
  end
  
  def combat_round
    form_lines
    determine_initiative
    determine_range
    combat_step
    breakthrough_step
    repair_step
    @round += 1
  end
  
  def combat_step(breakthrough=false)
    both_fleets(:reset_fired_counts)
    both_players(:begin_combat_step)
    
    n = [fleet1.size, fleet1.size].max
    (0...n).each do |i|
      # Ships need to be sorted by size first
      unless breakthrough
        attacker.battle_line[i].expose_to_fire(defender) if attacker.ships[i]
        defender.battle_line[i].expose_to_fire(attacker) if defender.ships[i]
      else
        if breakthrough == :fleet1
          fleet2.reserve[i].expose_to_fire(fleet1) if fleet2.reserve[i]
        elsif breakthrough == :fleet2
          fleet1.reserve[i].expose_to_fire(fleet2) if fleet1.reserve[i]
        end
      end
    end
    both_fleets(:apply_damage)
  end
  
  def determine_initiative
    fleet1_dm = 0
    fleet2_dm = 0
    fleet1_dm += 1 if fleet1.least_agility > fleet2.least_agility
    fleet2_dm += 1 if fleet2.least_agility > fleet1.least_agility
    fleet1_dm += 1 if fleet1.ships.length > fleet2.ships.length
    fleet2_dm += 1 if fleet2.ships.length > fleet1.ships.length
    roll1 = TCS.roll + fleet1_dm
    roll2 = TCS.roll + fleet2_dm
    if roll1 > roll2
      @attacker = fleet1
    elsif roll2 > roll1
      @attacker = fleet2
    else
      determine_initiative
    end
  end
  
  def determine_range
    if @round == 1
      @range = :long 
    else
      @range = @attacker.player.choose_range
    end
  end
  
  def form_lines
    both_fleets(:form_lines)
    player1.see_lines(fleet2)
    player2.see_lines(fleet1)
  end
  
  def player1
    fleet1.player
  end
  
  def player2
    fleet2.player
  end
  
  def repair_step
    both_fleets(:repair)
  end
  
  def run
    while fleet1.size > 0 && fleet2.size > 0
      combat_step
    end
  end
end