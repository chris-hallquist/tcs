require 'rspec'
require 'ship'

describe Battery do
  let(:e) { Eurisko.new }
  let(:m) { Missile.new(3, 1, 6) }
  let(:g) { MesonGun.new(12, 1, 6) }
  context 'when the battery is a Missile' do
    it 'should always hit Eurisko-class ships' do
      expect((0...72).all? { m.hit?(e, :long) }).to be_true
    end
  end
end