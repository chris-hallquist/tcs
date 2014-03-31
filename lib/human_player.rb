class HumanPlayer
  def assign_damage(choices)
    puts "Assign damage:"
    choices.each_with_index do |choice, i|
      puts "#{i}. #{choice}"
    end
    puts "(Enter a number)"
    gets.to_i
  end
  
  def choose_range
    puts "Choose range:"
    puts "0. Short"
    puts "1. Long"
    puts "(Enter a number)"
    gets.to_i == 0 ? :short : :long
  end
end