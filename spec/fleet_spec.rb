require 'rspec'
require 'ship'
require 'fleet'
require 'computer_player'

describe Fleet do
  let(:lenat) { Lenat.new(ComputerPlayer.new) }
  context 'when fleet design is Lenat\'s' do
    it 'should cost no more than 1 trillion credits' do
      expect(lenat.cost).to be <= 1_000_000_000_000
    end
    it 'should require no more than 200 pilots' do
      expect(lenat.pilots).to be <= 200
    end
    it 'should be capable of jump 3' do
      expect(lenat.tcs_valid_jump?).to be_true
    end
    it 'should not be capable of jump 3 after adding another Bee' do
      lenat.ship_counts[-1] += 1
      expect(lenat.tcs_valid_jump?).to be_false
    end
  end
end