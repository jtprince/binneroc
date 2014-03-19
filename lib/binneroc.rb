require "binneroc/version"

module Binneroc

  class << self

    # returns (new_x_coords, new_y_coords)
    # Where:
    #   xvec = the current x coordinates
    #   yvec = the parallel y coords 
    #   start = the initial x point, or floor of lowest x value
    #   stop = the final point, or ceil of highest x value
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
    def bin(xvec, yvec, start: nil, stop: nil, increment: 1.0, baseline: 0.0, behavior: :sum, outputclass: Array, return_xvec: true)

      if start.nil? && stop.nil?
        (min, max) = xvec.minmax
      elsif start.nil?
        min = xvec.min
      elsif stop.nil?
        max = xvec.max
      end
      start = min.floor.to_f if min
      stop = max.ceil.to_f if max

      scale_factor = 1.0/increment
      start_scaled = (start * scale_factor + 0.5).to_int 
      stop_scaled = (stop * scale_factor + 0.5).to_int 

      # the size of the yvec will be: [start_scaled..stop_scaled] = stop_scaled - start_scaled + 1
      ## the x values of the incremented vector: 
      xvec_new_size = (stop_scaled - start_scaled + 1)
      xvec_new = outputclass.new(xvec_new_size)
      # We can't just use the start and stop that are given, because we might
      # have needed to do some rounding on them
      end_unscaled = stop_scaled / scale_factor
      start_unscaled = start_scaled / scale_factor
      xval_new = start_unscaled
      xvec_new_size.times do |i|
        xvec_new[i] = start_unscaled
        start_unscaled += increment
      end

      # special case: no data
      if xvec.size == 0
        yvec_new = outputclass.new(xvec_new.size, baseline)
        return [xvec_new, yvec_new]
      end

      ## SCALE the mz_scaled vector
      xvec_scaled = xvec.collect do |val|
        (val * scale_factor).round
      end

      ## FIND greatest index
      _max = xvec_scaled.last

      ## DETERMINE maximum value
      max_ind = stop_scaled
      if _max > stop_scaled
        max_ind = _max ## this is because we'll need the room
      end

      lshift = start_scaled

      ## CREATE array to hold mapped values and write in the baseline
      yvec_new = outputclass.new(max_ind+1-start_scaled, baseline)
      nobl = outputclass.new(max_ind+1, 0) unless behavior == :max_x

      case behavior
      when :sum
        xvec_scaled.each_with_index do |ind,i|
          val = yvec[i]
          yvec_new[ind-lshift] = nobl[ind] + val
          nobl[ind] += val
        end
      when :max_x  ## FASTEST BEHAVIOR
        xvec_scaled.each_with_index do |ind,i|
          yvec_new[ind-lshift] = yvec[i]
        end
      when :avg
        count = Hash.new {|s,key| s[key] = 0 }
        xvec_scaled.each_with_index do |ind,i|
          val = yvec[i]
          yvec_new[ind-lshift] = nobl[ind] + val
          nobl[ind] += val
          count[ind] += 1
        end
        count.each do |k,co|
          if co > 1;  yvec_new[k-lshift] /= co end
        end
      when :max_y
        xvec_scaled.each_with_index do |ind,i|
          val = yvec[i]
          if val > nobl[ind]
            yvec_new[ind-lshift] = val
            nobl[ind] = val 
          end
        end
      when :max_yb
        xvec_scaled.each_with_index do |ind,i|
          val = yvec[i]
          if val > yvec_new[ind-lshift]
            yvec_new[ind-lshift] = val 
          end
        end
      else 
        abort "Not a valid behavior: #{behavior.inspect}"
      end

      [xvec_new, yvec_new]
    end
  end
end
