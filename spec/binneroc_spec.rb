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

    reply = Binneroc.bin([],[], return_xvals: false)
    expect(reply).to eq []
  end
end

describe 'super simple case' do
  let(:vals) {
    [
      [3.15],
      [   4]
    ]
  }

  specify 'does not bin values outside the range' do
    reply = Binneroc.bin(*vals, start: 3.5, stop: 4.0, increment: 1.0)
    expect(reply).to eq [[3.5], [0.0]]
  end

  specify 'does not exclude the end point by default' do
    reply = Binneroc.bin(*vals, start: 3.0, stop: 4.0, increment: 1.0)
    expect(reply).to eq [[3.0, 4.0], [4, 0]]
  end

  specify 'can exclude the final end value' do
    reply = Binneroc.bin(*vals, start: 3.0, stop: 4.0, exclude_end: true, increment: 1.0)
    expect(reply).to eq [[3.0], [4]]
  end

  specify 'can use a default value' do
    reply = Binneroc.bin(*vals, start: 3.0, stop: 4.0, exclude_end: false, increment: 1.0, default: 7.7)
    expect(reply).to eq [[3.0, 4.0], [4.0, 7.7]]
  end

  specify 'can add to a default value' do
    reply = Binneroc.bin(*vals, start: 3.0, stop: 4.0, exclude_end: false, increment: 1.0, default: 7.7, consider_default: true)
    expect(reply).to eq [[3.0, 4.0], [11.7, 7.7]]
  end

end

describe 'iconic case' do
  let(:vals) {
    [
      [4.0, 4.01, 4.15, 4.2, 5.0],
      [10,    20,   30,  40,  50]
    ]
  }

  specify 'works' do
    reply = Binneroc.bin(*vals, start: 4.0, stop: 5.0, increment: 0.1)
    expect(reply).to eq [(4..5).step(0.1).to_a, [30.0, 30.0, 40.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 50.0]]
  end

  specify 'accepts string values (for BigDecimal)' do
    reply = Binneroc.bin(*vals, start: "4.0", stop: "5.0", increment: "0.1")
    expect(reply).to eq [(4..5).step(0.1).to_a, [30.0, 30.0, 40.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 50.0]]
  end

  specify 'can avoid returning the x values' do
    reply = Binneroc.bin(*vals, start: "4.0", stop: "5.0", increment: "0.1", return_xvals: false)
    expect(reply).to eq [30.0, 30.0, 40.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 50.0]
  end

end
