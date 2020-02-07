# Binneroc

Bins in constant time, O(c) or O(1).

# Example

My use case is a spectrum of x,y data points (an x position associated with
some intensity y).  You would like to bin the signal into discrete bin points
such that all the intensity is associated with equally spaced bins.  The
simple algorithm used here finds the proper bin in constant time.

xvals = [3.3, 4.5, 6.6]
yvals = [4,    10,   2]

(newx, newy) = Binneroc.bin(xvals, yvals)

## Installation

    gem install binneroc

## Copyright

MIT License.  See LICENSE.txt.
