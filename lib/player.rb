class Player
  attr_accessor :fleet, :game, :enemy
  
  def initialize(options = {})
    @fleet = options[fleet]
    @game = options[game]
    @enemy = options[enemy]
  end
end  