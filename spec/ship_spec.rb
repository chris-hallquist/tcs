require 'rspec'
require 'ship'

describe Ship do
  let(:eurisko) { Eurisko.new }
  context 'when ship is Eurisko class' do
    it 'should have maneuver 1 with drop tanks' do
      expect(eurisko.maneuver_with_tanks).to be(1)
    end
  end
end