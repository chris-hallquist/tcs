class StarshipCombat
  attr_accessor :fleet1, :fleet2
  
  def initialize(fleet1, fleet2)
    @fleet1 = fleet1
    @fleet2 = fleet2
    @round = 1
  end
  
  def combat_round
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
  end
end