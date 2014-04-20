require 'rspec'
require 'ship'

describe Battery do
  let(:e) { Eurisko.new }
  let(:w) { Wasp.new }
  let(:m) { Missile.new(3, 1, 6) }
  let(:g) { MesonGun.new(12, 1, 6) }
  context 'when the battery is a Missile' do
    it 'should always hit Eurisko-class ships' do
      srand 0
      expect((0..71).all? { m.hit?(e, :long) }).to be_true
    end
    it 'should usually hit Wasp-class ships' do
      srand 0
      expect((0..7).all? { m.hit?(w, :long) }).to be_true
    end
    it 'should sometimes miss Wasp-class ships' do
      expect(m.hit?(w, :long)).to be_false
    end
  end
end