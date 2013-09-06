#!/usr/bin/env ruby

# Wrapper for LZH compression/decompression library.

require 'ffi'

module LzhWrapper
  extend FFI::Library
  ffi_lib File.expand_path(File.dirname(__FILE__) + "/lib/liblzh.dylib")
  attach_function :DecodedLength, [:pointer], :int
  attach_function :Decode, [:pointer, :pointer], :int
  attach_function :Encode, [:pointer, :int, :pointer], :int

  # lzh decompress
  # input is string of escaped bytes
  def self.decode(str)
    len = DecodedLength(str)
    # allocate buffer for output
    output = FFI::MemoryPointer.new(:char, len)
    
    Decode(str, output)
    
    return output.get_bytes(0, len)
  end
  
  # lzh compress
  # input is string of escaped bytes
  def self.encode(str)
    output = FFI::MemoryPointer.new(:uchar, str.length*2) # don't know how output space we will need, but this should be safe
    len = Encode(str, str.length, output)
    
    return output.get_bytes(0, len)
  end
  
end

if $0 == __FILE__
  include LzhWrapper
  require_relative 'string_tools'
  
  require 'test/unit'

  class LzoWrapperTest < Test::Unit::TestCase
    @@uncompresseddata = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    @@compresseddata = "\xBE\x01\x00\x00\xEC~\xFF\xDF\x1F\xCE\xB3\xEB\xFC\xFF\x80\xE0\xE0|1?\x16\xB0\xED^\xDF\x80[\xF6\xD6\xC2\xB5\xDCS\xEF\xB9\xFA\xA3V\xC2\xA5j\xB7\x95)\xB4\xBB\xA3}F\xBC3\xE5\x97\xF9\xD1\r\xD4\xF7\x00\xEC\x11\xC6\x89\x18\xD1,\xF1\xA1\xB3\x04\xC6?+\xB0\xDD\x8FY\x12\x93\x18src>\xC5\xA0cu\xBE\xE8\xE4\xFB\x13\x15\xCC\x9BK\x97\x854\x9A.N\e?\xA9\xB5\xBA\x7F\x84\xEFJ\x8Bm\x02p\x9C]\xFC\x10\x04\x889\xD1\xD8\x8C\x02\xECXUEs\xD4iRG\xD1\x02\b\xC3\x04\xDEEb\xF4a\x82\x12\xD4\x81&[D\x88\x9A\x9F\xC5L\xD0\x92\xF4\x84\xC5\x82\x82r|\x87\xE3O\xB0h\x0F\xE5Q\x9B\xC1\xE0\x94\x92'\xC6@t\xAF\x80i\x97K;\xC8\x94\x8E\xA6\xEA)\xAEU\xDE\x81NH\x10l\xDC\x9F\xBD\x94\xAE\xD9\x8C\xEC%#\xBD4\xE8\x91\xB2\xF0\xBD\xAA,\"\x00\x18\x90@o\xF2\aZ\x8D\x00\x03\xFD0\f\x06\x9E\xE0yI+c\x13\x99V:\xEF*\x0FK\xB0\xFF\xD8\xE4O\x88\xAD\xDD\xDF\xE4\x95\xCA-\xD0_\x9EZ\xBB\xDDeX\xBD\x95N\x8C^\xA9v\x13\xFA\x9B\xC7\x03\xD6\xBA\\\xD5\x9B\xFB\x9Fx\xB0;\x8F7XcV\xD5A\xAD\xA8\xEC\xDFK^\x99|\x80".force_encoding(Encoding::ASCII_8BIT)
    
    def test_encode
      assert_equal(@@compresseddata, LzhWrapper.encode(@@uncompresseddata))
    end

    def test_decode
      assert_equal(@@uncompresseddata, LzhWrapper.decode(@@compresseddata))
    end

  end
  
end

