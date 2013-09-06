#!/usr/bin/env ruby

module ArrayTools

  def to_hex(delim='')
    self.map { |x| "%02X" % x }.join(delim)
  end
  
  def to_ascii
    self.map { |x| x.chr}.join().force_encoding(Encoding::ASCII_8BIT)
  end

  # Renders array as formatted C Array with a separate const length variable.
  def to_c_array
    output = "const unsigned long buflen = %d;\n" % self.length
    output += "unsigned char buf[buflen] = { \\\n\t"
    self.each_with_index do |b, i|
      output += "0x%02X" % b
      if i < self.length - 1
        if (i+1)%16 == 0
          output += ", \\\n\t"
        else
          output += ", "
        end
      end
    end
    output += " \\\n};\n"
  end
  
end

# Make our tools available to the Array class
class Array
  include ArrayTools
end

if $0 == __FILE__
  require 'test/unit'
 
  class ArrayToolsTest < Test::Unit::TestCase
    
    def test_to_hex
      assert_equal("48 65 6C 6C 6F 20 57 6F 72 6C 64", [72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100].to_hex)
    end
    
    def test_to_ascii
      assert_equal("\x17\xE8{\x8F".force_encoding(Encoding::ASCII_8BIT), [23, 232, 123, 143].to_ascii)
    end
    
  end
end