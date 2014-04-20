require 'rspec'
require 'starship_combat'

describe StarshipCombat do
  let(:c) { ComputerPlayer.new }
  let(:f1) { OneEurisko.new(c) }
  let(:f2) { OneEurisko.new(c) }
  let(:sc) { StarshipCombat.new(f1, f2) }
  
  context 'when two Eurisko-class ships fight' do
    it 'shoud produce a single winner' do
      sc.run
      expect(f1.size > 0 ^ f2.size > 0).to be_true
    end
  end
end