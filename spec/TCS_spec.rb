require 'rspec'
require 'TCS'

describe TCS do
  context 'when the random number generator\'s seed is set to 0' do
    it 'shoud give the first 10 rolls as 11, 5, 8, 6, 9, 6, 6, 5, 3, 8' do
      srand 0
      ((0..9).collect { TCS.roll }).should 
        equal([11, 5, 8, 6, 9, 6, 6, 5, 3, 8])
    end
  end
end