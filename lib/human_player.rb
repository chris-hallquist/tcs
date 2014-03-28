class HumanPlayer
  def assign_damage(choices)
    choices.each_with_index do |choice, i|
      puts "#{i}. #{choice}"
    end
    puts "Enter a number"
    gets
  end
end