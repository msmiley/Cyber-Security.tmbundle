#!/usr/bin/env ruby


class StatTools
  attr_reader :data, :length, :sum, :mean, :variance, :std_dev, :histogram
  
  def initialize(data)
    if data.class == String
      data = data.bytes
    end
    @data = data
    @length = @data.length
    @sum = @data.inject(0) { |accum, i| accum + i }
    @mean = @sum/@length.to_f
    @varsum = @data.inject(0) { |accum, i| accum + (i - @mean) ** 2 }
    @variance = @varsum / (@length - 1).to_f
    @std_dev = Math.sqrt(@variance)
    @histogram = self.byte_histogram(@data)
    return true
  end
  
  def inspect
    "data with length = #{@length}"
  end
  
  def entropy    
    ent = 0.0
    @histogram.each do |f|
      if f > 0
        freq = f.to_f / @data.length
        ent = ent + freq * (Math.log(freq)/Math.log(2))
      end
    end
    return -ent
  end
  
  def byte_histogram(data)
    if data.class == String
      data = data.bytes
    end
    hist = [0]*256
    data.each do |e|
      hist[e] += 1
    end
    return hist
  end
  
  
end


if $0 == __FILE__
  include StatTools
  require 'test/unit'
 
  class StatToolsTest < Test::Unit::TestCase
    
    def test_entropyWithData
      assert_equal(StatTools.entropyWithData([1, 255]), 1.0)
      assert_equal(StatTools.entropyWithData("\x00\xff"), 1.0)
    end
  end
  
  
end