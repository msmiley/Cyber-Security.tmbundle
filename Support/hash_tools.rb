#!/usr/bin/env ruby

require 'openssl'

require_relative 'string_tools'

# HashTools contains methods which aid in obtaining hashes of data.
module HashTools
  
  # Calculates and returns a string containing the MD5 hash of the given comma/space/non-delimited hex bytes.
  def self.hashWithHexBytes(hash, hexbytes)
    str = hexbytes.extract_to_string
    digest = OpenSSL::Digest.digest(hash, str)
  end
  
  # Calculates and returns a string containing the MD5 hash of the given string.
  def self.hashWithString(hash, str)
    digest = OpenSSL::Digest.digest(hash, str)
  end
  
end


if $0 == __FILE__
  include HashTools
  require 'test/unit'
 
  class HashToolsTest < Test::Unit::TestCase

    def test_md5WithHexStream
      assert_equal(HashTools.hashWithHexBytes("MD5", "426F44494D4C78556E35484537327445316E5146326453695641".delimit), "H\vucS\xF20\x95\tx\xDC\xD0\xA5\x8B\x10\xFF".force_encoding(Encoding::ASCII_8BIT))
      assert_equal(HashTools.hashWithHexBytes("MD5", "42,6F,44,49,4D,4C,78,55,6E,35,48,45,37,32,74,45,31,6E,51,46,32,64,53,69,56,41"), "H\vucS\xF20\x95\tx\xDC\xD0\xA5\x8B\x10\xFF".force_encoding(Encoding::ASCII_8BIT))
    end
    
    def test_md5WithString
      assert_equal(HashTools.hashWithString("MD5", "BoDIMLxUn5HE72tE1nQF2dSiVA"), "H\vucS\xF20\x95\tx\xDC\xD0\xA5\x8B\x10\xFF".force_encoding(Encoding::ASCII_8BIT))
    end
        
  end
end
