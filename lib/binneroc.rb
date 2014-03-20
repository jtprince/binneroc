require "binneroc/version"
require 'bigdecimal'

if RUBY_VERSION == '2.1.0'
  STDERR.puts "You are using a version of ruby with a known bug in BigDecimal division."
  STDERR.puts "This is fixed in newer versions of ruby.  Please upgrade"
  raise
end

module Binneroc

  class << self
    # if converting from a floating point number, the precision to use
    BIG_DECIMAL_PRECISION = 10
  
    # returns (new_x_coords, new_y_coords)
    #
    # each bin is the *minimum* for that bin. i.e., the bin includes all
    # values starting at that point non-inclusive to that point + increment.
    #
    # Example: 
    # 
    # 
    # Note: The final bin + increment may exceed the :stop value.
    # Note: Values falling outside the range of start to final bin + increment
    # will not be included.
    #
    #     xvals = the current x coordinates
    #     yvals = the parallel y values
    #
    #     start = the starting x point for binning 
    #                 if nil then floor of lowest xvals value
    #     stop  = no more bins created after stop
    #                 if nil then ceil of highest xvals value
    #     increment = the x coordinate (binning) increment
    #     exclude_end = *false|true how to treat stop value
    #
    #     default = the default value if no values lie in a bin
    #               note that values are not added on top of the default
    #               it is just the value used if there are no values for a bin
    #
    #     consider_default = true: treat the default value as the first value in the bin
    #                        false: default considered only if no values fall in the bin
    #
    #     outputclass = (Array) make new arrays using this class
    #                   needs to accept 
    #                       ::new(array)
    #                       ::new(size)
    #                       ::new(size, default)
    #
    #     behavior = response when multiple values fall to the same bin
    #         sum => sums all values
    #         # below are not yet implemented but could easily be:
    #         avg => avgs the values # not yet implemented 
    #         max_x => takes the value at the highest x coordinate
    #         max_y => takes the value of the highest y value (even if lower than baseline)
    #         max_yb => takes the highest y value (includes the baseline)
    #
    #     return_xvals = true|false (default true)
    #
    # outputclass needs to be able to create a new vector like object with the
    # arguments outputclass.new(size, value) or outputclass.new(size).
    def bin(xvals, yvals, start: nil, stop: nil, increment: 1.0, default: 0.0, behavior: :sum, outputclass: Array, return_xvals: true, exclude_end: false, consider_default: false, only_xvals: false)
      raise ArgumentError, "xvals and yvals need to be parallel (same size)!" unless xvals.size == yvals.size

      if xvals.size == 0
        if return_xvals && !only_xvals
          return [[],[]]
        else
          return []
        end
      end

      increment = increment.to_f unless increment.is_a?(Float)

      if start.nil? && stop.nil?
        (min, max) = xvals.minmax
      elsif start.nil?
        min = xvals.min
        stop = stop.to_f
      elsif stop.nil?
        max = xvals.max
        start = start.to_f
      end
      start = min.floor.to_f if min
      stop = max.ceil.to_f if max

      (startbd, stopbd, incrementbd) = [start, stop, increment].map do |v| 
        if v.is_a?(Float) 
          BigDecimal.new(v, BIG_DECIMAL_PRECISION)
        else
          BigDecimal.new(v)
        end
      end

      newsize = array_size(startbd, stopbd, incrementbd, exclude_end)
      range = Range.new(startbd, startbd + (incrementbd * newsize), exclude_end)

      if return_xvals
        basic_xvals = range.step(incrementbd).to_a
        basic_xvals.pop if basic_xvals.size > newsize
        new_xvals = outputclass.new(basic_xvals)
      end
      return new_xvals if only_xvals

      yvec_new = outputclass.new(newsize, default)
      index_bounds = (0...newsize)

      case behavior
      when :sum
        if consider_default
          xvals.zip(yvals) do |x, y|
            index = ((x-startbd) / incrementbd).floor # round??
            if index_bounds===(index)
              yvec_new[index] += y 
            end
          end
        else
          no_default = outputclass.new(newsize, 0.0)
          xvals.zip(yvals) do |x, y|
            index = ((x-startbd) / incrementbd).floor # round??
            if index_bounds===(index)
              yvec_new[index] = no_default[index] + y
              no_default[index] += y 
            end
          end
        end
      end

      if return_xvals
        [new_xvals, yvec_new]
      else
        yvec_new
      end
    end

    # calculates the number of items that should be in the array.
    def array_size(start, stop, step, exclude_end=false)
      fractional_arr_sz = (stop - start) / step
      array_size_floor = fractional_arr_sz.floor
      array_size_floor += 1 unless exclude_end && (array_size_floor == fractional_arr_sz)
      array_size_floor.to_i
    end

    # takes the x array and the arguments and produces the xvals that would be
    # produced with bin
    def xvals(xvals, **args)
    end

  end
end



## reference from old behavior

### CREATE array to hold mapped values and write in the baseline
#yvec_new = outputclass.new(max_ind+1-start_scaled, baseline)
#nobl = outputclass.new(max_ind+1, 0) unless behavior == :max_x

#case behavior
#when :sum
  #xvec_scaled.each_with_index do |ind,i|
    #val = yvec[i]
    #yvec_new[ind-lshift] = nobl[ind] + val
    #nobl[ind] += val
  #end
#when :max_x  ## FASTEST BEHAVIOR
  #xvec_scaled.each_with_index do |ind,i|
    #yvec_new[ind-lshift] = yvec[i]
  #end
#when :avg
  #count = Hash.new {|s,key| s[key] = 0 }
  #xvec_scaled.each_with_index do |ind,i|
    #val = yvec[i]
    #yvec_new[ind-lshift] = nobl[ind] + val
    #nobl[ind] += val
    #count[ind] += 1
  #end
  #count.each do |k,co|
    #if co > 1;  yvec_new[k-lshift] /= co end
  #end
#when :max_y
  #xvec_scaled.each_with_index do |ind,i|
    #val = yvec[i]
    #if val > nobl[ind]
      #yvec_new[ind-lshift] = val
      #nobl[ind] = val 
    #end
  #end
#when :max_yb
  #xvec_scaled.each_with_index do |ind,i|
    #val = yvec[i]
    #if val > yvec_new[ind-lshift]
      #yvec_new[ind-lshift] = val 
    #end
  #end
#else 
  #abort "Not a valid behavior: #{behavior.inspect}"
#end

#if return_new_xvals
  #xvec_new = outputclass.new(newsize) 
  #Range.new(start, stop, exclude_end).step(increment).each_with_index do |v,i|
    #xvec_new[i] = v
  #end
#end

