require 'rspec'
require 'ship'

describe Ship do
  let(:eurisko) { Eurisko.new }
  context 'when ship is Eurisko class' do
    it 'should have maneuver 1 when drop tanks are attached' do
      expect(eurisko.maneuver_with_tanks).to be(1)
    end
    it 'should have enough fuel' do
      expect(eurisko.valid_fuel?).to be_true
    end
  end
end