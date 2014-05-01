require 'rspec'
require 'ship'
require 'computer_player'

describe Battery do
  let(:e) { Eurisko.new }
  let(:w) { Wasp.new }
  let(:m) { Missile.new(3, 1, 6, 1) }
  let(:g) { MesonGun.new(12, 1, 6, 1) }
  let(:c) { ComputerPlayer.new }
  context 'when the battery is a Missile' do
    it 'should sometimes hit Eurisko-class ships' do
      srand 0
      expect(m.hit?(e, :long)).to be_true
    end
    it 'should sometimes miss Eurisko-class ships' do
      expect(m.hit?(e, :long)).to be_false
    end
    it 'should sometimes hit Wasp-class ships' do
      srand 0
      expect(m.hit?(w, :long)).to be_true
    end
    it 'should almost always miss Wasp-class ships' do
      expect((0..24).none? { m.hit?(w, :long) }).to be_true
    end
    it 'usually shouldn\'t damage Eurisko-class ships' do
      srand 0
      4.times { m.roll_damage(e, c) }
      expect(e.shadow.hits.size).to be 0 
    end
    it 'should sometimes damage Eurisko-class ships' do
      m.roll_damage(e, c)
      expect(e.shadow.hits.size).to be > 0
    end
  end
end