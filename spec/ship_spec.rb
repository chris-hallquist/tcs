require 'rspec'
require 'ship'
require 'fleet'
require 'computer_player'

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
    it 'should have missile batteries with factor 3' do
      expect(eurisko.missile).to be 3
    end
    it 'should have 29 missile batteries' do
      expect(eurisko.missile_count).to be 29
    end
    it 'should not be streamlined' do
      expect(eurisko.streamlined?).to be_false
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
    it 'should be streamlined' do
      expect(garter.streamlined?).to be_true
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