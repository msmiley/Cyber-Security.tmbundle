#!/usr/bin/env ruby


module XORTools
  
  # XOR input array with a single byte key, return is array.
  def self.singleByteXORWithAry(key, inbytes)
    inbytes.map { |x| x^key }
  end

  def self.singleByteXORWithString(key, str)
    ary = str.bytes
    singleByteXORWithAry(key, ary)
  end

end

if $0 == __FILE__
  include XORTools
  require 'test/unit'
 
  class XORToolsTest < Test::Unit::TestCase
    
    @@testarray = [104, 101, 108, 108, 111]

    def test_singleByteXORWithAry
      assert_equal(XORTools.singleByteXORWithAry(0x29, @@testarray), [65, 76, 69, 69, 70])
    end
    
    def test_singleByteXORWithString
      assert_equal(XORTools.singleByteXORWithString(0x29, "hello"), [65, 76, 69, 69, 70])
    end
    
  end
end