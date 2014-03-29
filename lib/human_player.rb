class HumanPlayer
  def assign_damage(choices)
    puts "Assign damage:"
    choices.each_with_index do |choice, i|
      puts "#{i}. #{choice}"
    end
    puts "(Enter a number)"
    gets.to_i
  end
end