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
  end
end