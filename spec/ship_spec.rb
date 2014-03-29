require 'rspec'
require 'ship'

describe Ship do
  let(:eurisko) { Eurisko.new }
  let(:cisor) { Cisor.new }
  let(:garter) { Garter.new }
  let(:queller) { Queller.new }
  context 'when ship is Eurisko class' do
    it 'should have maneuver 1 when drop tanks are attached' do
      expect(eurisko.maneuver_with_tanks).to be(1)
    end
    it 'should have enough fuel' do
      expect(eurisko.valid_fuel?).to be_true
    end
    it 'should be a valid design' do
      expect(eurisko.valid?).to be_true
    end
    it 'should have mass within 3% of the official value' do
      expect((eurisko.tons_used / eurisko.tons - 1).abs).to be < 0.03
    end
    it 'should have cost within 3% of the official value' do
      expect((eurisko.cost / 13_030_385_000 - 1).abs).to be < 0.03
    end
  end
  context 'when ship is Cisor class' do
    it 'should have mass within 3% of the official value' do
      expect((cisor.tons_used / cisor.tons - 1).abs).to be < 0.03
    end
    it 'should have cost within 3% of the official value' do
      expect((cisor.cost / 22_291_175_000 - 1).abs).to be < 0.03
    end
  end
  context 'when ship is Garter class' do
    it 'should have mass within 3% of the official value' do
      expect((garter.tons_used / garter.tons - 1).abs).to be < 0.03
    end
    it 'should have cost within 3% of the official value' do
      expect((garter.cost / 17_584_104_000 - 1).abs).to be < 0.03
    end
  end
  context 'when ship is Queller class' do
    it 'should have mass within 3% of the official value' do
      expect((queller.tons_used / queller.tons - 1).abs).to be < 0.03
    end
    it 'should have cost within 3% of the official value' do
      expect((queller.cost / 27_802_392_000 - 1).abs).to be < 0.03
    end
  end
end