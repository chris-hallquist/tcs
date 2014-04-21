require 'rspec'
require 'computer_player'
require 'ship'
require 'fleet'

describe ComputerPlayer do
  let(:c1) { ComputerPlayer.new }
  let(:c2) { ComputerPlayer.new }
  let(:f1) { OneEurisko.new(c1) }
  let(:f2) { OneEurisko.new(c2) }
  let(:sc) { StarshipCombat.new(f1, f2) }
  let(:s1) { f1.ships[0] }
  
  context 'when assigning batteries' do
    it 'shoud assign at least one battery' do
      c2.begin_combat_step
      expect(c2.assign_batteries(f2, e1).size).to be > 0
    end
  end
end