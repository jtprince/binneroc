require "binneroc/version"

module Binneroc

  class << self

    # calculates the number of items that should be in the array.  Assumes
    # floats
    def array_size(start, stop, step, exclude_end=false)
      array_size = ((stop - start) / step).floor
      if (array_size.floor == array_size) && !exclude_end
        array_size += 1
      end
      array_size
    end

    # returns (new_x_coords, new_y_coords)
    #
    # each bin is the *minimum* for that bin. i.e., the bin includes all
    # values starting at that point non-inclusive to that point + increment.
    #
    # Binneroc.bin([4.5], [7], start: 4.0, increment: 1.0) => 
    #   [[4.0], [7]]
    #
    # Note: the final bin + increment may exceed the :stop value.
    #
    # Where:
    #   xvec = the current x coordinates
    #   yvec = the parallel y coords 
    #   start = the initial x point; if nil then floor of lowest x value
    #   stop = the final point; if nil then ceil of highest x value
    #
    #   increment = the x coordinate increment
    #   baseline = the default value if no values lie in a bin
    #   behavior = response when multiple values fall to the same bin
    #     sum => sums all values
    #     avg => avgs the values
    #     max_x => takes the value at the highest x coordinate
    #     max_y => takes the value of the highest y value (even if lower than baseline)
    #     max_yb => takes the highest y value (includes the baseline)
    #
    # outputclass needs to be able to create a new vector like object with the
    # arguments outputclass.new(size, value) or outputclass.new(size).
    def bin(xvec, yvec, start: nil, stop: nil, increment: 1.0, baseline: 0.0, behavior: :sum, outputclass: Array, return_xvec: true, exclude_end: false)
      raise ArgumentError, "xvec and yvec need to be parallel (same size)!" unless xvec.size == yvec.size

      if xvec.size == 0
        if return_xvec
          return [[],[]]
        else
          return []
        end
      end

      increment = increment.to_f unless increment.is_a?(Float)

      if start.nil? && stop.nil?
        (min, max) = xvec.minmax
      elsif start.nil?
        min = xvec.min
        stop = stop.to_f
      elsif stop.nil?
        max = xvec.max
        start = start.to_f
      end
      start = min.floor.to_f if min
      stop = max.ceil.to_f if max

      newsize = array_size(start, stop, increment, exclude_end)
      range = Range.new(start, start + (increment * newsize), exclude_end)
      p range

      yvec_new = outputclass.new(newsize, baseline)

      case behavior
      when :sum
        xvec.zip(yvec) do |x, y|
          index = (x / increment).floor # round??
          unless index < 0 || index >= newsize
            yvec_new[index] += y
          end
        end
      end

      if return_xvec
        ar = range.step(increment).to_a
        ar.pop
        [ar, yvec_new]
      else
        yvec_new
      end
    end
  end
end


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

      #if return_xvec
        #xvec_new = outputclass.new(newsize) 
        #Range.new(start, stop, exclude_end).step(increment).each_with_index do |v,i|
          #xvec_new[i] = v
        #end
      #end

#      [xvec_new, yvec_new]
    #end
  #end
#end
