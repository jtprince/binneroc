require 'spec_helper'

require 'binneroc'

describe 'binning with no data' do
end

describe 'simple case' do




  let(:xvals) {[3.3, 4.5, 6.6]}
  let(:yvals) {[4,    10,   2]}

  it 'bins' do
    (new_xvals, new_yvals) = Binneroc.bin(xvals, yvals, start: 3.5, stop: 6.0)

    p new_xvals
    p new_yvals

    #expect(new_xvals).to eq [3.0, 4.0, 5.0, 6.0, 7.0]
    #expect(new_yvals).to_eq [4, 0.0, 10, 0.0, 2]
  end
end

