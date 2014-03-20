require 'spec_helper'

require 'binneroc'

describe 'determining the number of bins' do
  specify 'not excluding the end' do
    args = [0.0, 1.0, 0.1, false]

    ans = Binneroc.array_size(*args)
    expect(ans).to eq 11
  end

  specify 'excluding the end' do
    args = [0.0, 1.0, 0.1, true]

    ans = Binneroc.array_size(*args)
    expect(ans).to eq 10
  end

  specify 'finding with other weird values' do
    args = [0.0, 1.0, 0.4, false]

    ans = Binneroc.array_size(*args)
    expect(ans).to eq 3
  end

end

describe 'binning with no data' do
  it 'works' do
    (xs, ys) = Binneroc.bin([],[])
    expect(xs).to eq []
    expect(ys).to eq []

    reply = Binneroc.bin([],[], return_xvec: false)
    expect(reply).to eq []
  end
end

describe 'simplest cases' do
  let(:vals) {
    [
      [3.15],
      [   4]
    ]
  }

  it 'does not bin outside the range' do
    reply = Binneroc.bin(*vals, start: 3.5, stop: 4.0, increment: 1.0)
    expect(reply).to eq [[3.5], [0.0]]

    reply = Binneroc.bin(*vals, start: 3.0, stop: 4.0, increment: 1.0)
    expect(reply).to eq [[3.0], [0.0]]

  end
end

