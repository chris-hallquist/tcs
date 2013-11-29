class StarshipCombat
  def roll(n=2)
    sum = 0
    n.times { sum += rand(6) + 1 }
    sum
  end
end

