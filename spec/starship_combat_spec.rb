require 'rspec'
require 'starship_combat'
require 'computer_player'

describe StarshipCombat do
  let(:c1) { ComputerPlayer.new }
  let(:c2) { ComputerPlayer.new }
  let(:f1) { OneEurisko.new(c1) }
  let(:f2) { OneEurisko.new(c2) }
  let(:sc) { StarshipCombat.new(f1, f2) }
  
  context 'when two Eurisko-class ships fight' do
    it 'shoud produce a single winner in no more than 100 rounds' do
      sc.run(100)
      expect(f1.can_fire? ^ f2.can_fire?).to be_true
    end
  end
end