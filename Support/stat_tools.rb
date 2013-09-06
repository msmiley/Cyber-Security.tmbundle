#!/usr/bin/env ruby


module StatTools
  
  def self.entropyWithData(data)
    freqList = [0] * 256
    
    if data.class == String
      data = data.bytes
    end
    
    data.each do |b|
      freqList[b] += 1
    end
    
    ent = 0.0
    freqList.each do |f|
      if f > 0
        freq = f.to_f / data.length
        ent = ent + freq * (Math.log(freq)/Math.log(2))
      end
    end
    return -ent
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