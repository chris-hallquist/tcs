class StarshipCombat
  attr_accessor :fleet1, :fleet2
  
  def initialize(fleet1, fleet2)
    @fleet1 = fleet1
    @fleet2 = fleet2
    @round = 1
  end
  
  def both_fleets(method, *args)
    [fleet1, fleet2].each { |fleet| fleet.send(method, *args) }
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
    i = 0
    while i < fleet1.size && i < fleet2.size
      # Ships need to be sorted by size first
      # TODO: Write expose_to_fire
      attacker.ships[i].expose_to_fire(defender) if attacker.ships[i]
      defender.ships[i].expose_to_fire(attacker) if defender.ships[i]
    end
    both_fleets(:apply_damage)
    # Need to implement special rules for damage 
    # for spinal mounts and critical hits
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
    fleet1.player.see_lines(fleet2)
    fleet2.player.see_lines(fleet1)
  end
  
  def repair_step
    both_fleets(:repair)
  end
end