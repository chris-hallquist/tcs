class Player
  attr_accessor :fleet, :game
  
  def initialize(options = {})
    @fleet = options[fleet]
    @game = options[game]
  end
end  