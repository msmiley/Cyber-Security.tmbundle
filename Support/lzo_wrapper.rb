#!/usr/bin/env ruby

require 'ffi'

# Requires LZO library to be installed on system.
# If you are using Homebrew, (and if not, why not?)
# then run:
#
# brew install lzo
#

module LzoWrapper
  extend FFI::Library
  ffi_lib "liblzo2.dylib"
  attach_function :__lzo_init_v2, [:int, :int, :int, :int, :int, :int, :int, :int, :int, :int], :int
  attach_function :lzo1x_decompress, [:pointer, :uint, :pointer, :pointer, :int], :int
  attach_function :lzo1x_999_compress, [:pointer, :uint, :pointer, :pointer, :pointer], :int
  attach_function :lzo1x_optimize, [:pointer, :uint, :pointer, :pointer, :int], :int

  def self.lzo_init
    LzoWrapper.__lzo_init_v2(1, -1, -1, -1, -1, -1, -1, -1, -1, -1)
  end

  # lzo1x compress
  def self.lzo1x_compress_with_string(str)
    # allocate buffer for input
    input = FFI::MemoryPointer.new(:uchar, 16384)

    # create working buffer for lzo
    workMem = FFI::MemoryPointer.new(:uchar, 458752)

    # output buffer and pointer for output length
    output = FFI::MemoryPointer.new(:uchar, 16384)
    outLen = FFI::MemoryPointer.new(:uint, 1)
    
    optimized = FFI::MemoryPointer.new(:uchar, 16384)
    optimizedLen = FFI::MemoryPointer.new(:uint, 1)

    input.put_bytes(0, str);

    d = lzo1x_999_compress(input, input.size, output, outLen, workMem)
    lzo1x_optimize(output, outLen, optimized, optimizedLen, 0)

    return optimized.get_bytes(0, optimizedLen.get_uint32(0))
  end

  # lzo1x decompress
  # input is string of escaped bytes
  def self.lzo1x_decompress_with_string(str)
    # allocate buffer for input
    input = FFI::MemoryPointer.new(:uchar, 8192)

    # output buffer and pointer for output length
    output = FFI::MemoryPointer.new(:uchar, 131072)
    outLen = FFI::MemoryPointer.new(:uint, 1)

    input.put_bytes(0, str);

    d = lzo1x_decompress(input, str.length, output, outLen, 0)

    return output.get_bytes(0, outLen.get_uint32(0))
  end
  
end

if $0 == __FILE__
  include LzoWrapper
  require 'test/unit'

  class LzoWrapperTest < Test::Unit::TestCase

    

  end
  
end

