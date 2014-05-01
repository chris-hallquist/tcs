require 'rspec'
require 'starship_combat'
require 'computer_player'

describe StarshipCombat do
  context 'when a single Eurisko-class ship fights a large fleet' do
    let(:c1) { ComputerPlayer.new }
    let(:c2) { ComputerPlayer.new }
    let(:f1) { OneEurisko.new(c1) }
    let(:f2) { Lenat.new(c2) }
    let(:sc) { StarshipCombat.new(f1, f2) }
    
    context 'when the single Eurisko-class ship is exposed to fire' do
      before(:each) do
        srand 0
        sc.form_lines
        c2.begin_combat_step
        f1.ships[0].expose_to_fire(f2, :long)
      end
      it 'records hits' do
        expect(f1.ships[0].shadow.hits.length > 0).to be_true
      end
    end
  end
  
  context 'when two Eurisko-class ships fight' do
    let(:c1) { ComputerPlayer.new }
    let(:c2) { ComputerPlayer.new }
    let(:f1) { OneEurisko.new(c1) }
    let(:f2) { OneEurisko.new(c2) }
    let(:sc) { StarshipCombat.new(f1, f2) }
    
    context 'a ship that is exposed to fire once' do
      before(:each) do
        srand 0
        sc.form_lines
        c2.begin_combat_step
        f2.reset_fired_counts
        f1.ships[0].expose_to_fire(f2, :long)
      end
      it 'doesn\'t take damage' do
        expect(f1.ships[0].shadow.hits.length > 0).to be_false
      end
    end
    
    it 'both ships should still be able to fire after 100 rounds' do
      srand 0
      sc.run(100)
      expect(f1.can_fire? && f2.can_fire?).to be_true
    end
  end
  
  context 'when two copies of Lenat\'s fleet fight' do
    let(:c1) { ComputerPlayer.new }
    let(:c2) { ComputerPlayer.new }
    let(:f1) { Lenat.new(c1) }
    let(:f2) { Lenat.new(c2) }
    let(:sc) { StarshipCombat.new(f1, f2) }
  
    it 'shoud have a winner after 100 rounds' do
      srand 0
      sc.run(100)
      expect(f1.can_fire? ^ f2.can_fire?).to be_true
    end
  end
end