#!/usr/bin/env ruby

# StringTools contains methods which provide additional methods for working with Strings.
module StringTools
    
  # Regex which matches commonly used delimiters
  DELIMREGEX = /[.,:;\-\s](?:\s*)/n
  # Regex which matches 2 character hex bytes with some form of delimiting
  # Uses negative lookahead which is only supported in Ruby > 1.9
  HEXBYTEREGEX = /(?<=^|[,:\s])[A-Fa-f0-9]{2}(?=[,:\s]|$)/n
  # Regex matches hex streams (using Wireshark name and convention of continuous hex characters with no delimiter)
  HEXSTREAMREGEX = /^[A-Fa-f0-9]+$/n
  # Regex to find delimited integer values of any length
  DECINTREGEX = /(?<=^|[.,\s])[0-9]+(?=$|[.,\s])/n
  # Regex to find delimited 2-digit integers
  DECINTPAIRREGEX = /(?<=^|[.,\s])[0-9]{2}(?=$|[.,\s])/n
  # Regex to find ASCII columns in strings copied from Hex + ASCII (hex editor-like) views
  ASCIICOLUMNS = /(?<= |  )[ -~]{8} {1,2}[ -~]{8}($|\n)/n
  
  # Smart string extraction.
  # Looks for 4 different types of data:
  # - hexstream
  # - delimited hex
  # - delimited decimal integers
  # - plain-old characters
  # the prefer_hex parameter is used to provide a decision for ambiguous sequences
  # returns a tuple with found type as [0] and byte array as [1]
  def self.extract(str, prefer_hex=false)
    # see if str is a hex stream (i.e. 2f424efc32c4d)
    hexstream = str.match(HEXSTREAMREGEX)
    
    if hexstream != nil # hextream always wins since it's a strong match
      data = str.scan(/../).map { |x| x.hex }
      ["hexstream", data]
    else
      # remove ASCII columns since this might be copied from a hex table and they could interfere with hex byte search
      str = str.gsub(ASCIICOLUMNS, "")
      
      # look for delimited hex bytes (i.e. 34 5d bf)
      hexbytes = str.scan(HEXBYTEREGEX)
      hexmetric = hexbytes.length / (str.length/6.0)
    
      # look for dec ints (i.e. 23,4,65,7,8)
      decints = str.scan(DECINTREGEX)
      # if all matches are 2 digits, assume this is hex which just happens to have no abcdef
      decpairs = str.scan(DECINTPAIRREGEX)
      if decints == decpairs
        decmetric = 0
      else
        decmetric = decints.length / (str.length/6.0)
      end
      
      if hexmetric > 1 or decmetric > 1 or prefer_hex
         if hexmetric >= decmetric or prefer_hex
           data = hexbytes.map { |x| x.hex }
           ["hex", data]
         else
           data = decints.map { |x| x.to_i }
           ["dec", data]
         end
       else # treat as text and convert directly to bytes
         ["text", str.bytes]
       end
     end
  end
  
  def is_printable?
    self.scan(/[ -~]/).size
  end
  
  # Tries to determine the contents of string and act accordingly.
  # By default, preference will be given to whichever has more matches: hex or dec
  # Setting coerce parameter to "hex" or "dec" will give that type preference
  def extract_ary(prefer_hex=false)
    StringTools.extract(self, prefer_hex)[1] # only return array
  end
  
  def extract_to_string
    self.extract_ary.pack("C*")
  end
  
  def extract_to_readable
    output = []
    self.extract_ary.map do |x|
      if x > 31 and x < 127 # leave out non printables
        output << x.to_i.chr
      end
    end
    output.join.force_encoding(Encoding::ASCII_8BIT)
  end
  
  def extract_to_UTF_16LE
    self.extract_ary.pack("C*").force_encoding(Encoding::UTF_16LE)
  end
  
  def extract_to_escaped_string
    self.extract_to_string.inspect
  end
  
  # Searches for valid hex bytes in the given string
  # Returns bytes as a string of hex bytes with the given delimiter.
  def to_hex_stream(delim="")
    self.extract_ary.map { |x| "%02X" % x }.join(delim)
  end
  
  # Searches for valid decimal integers in the given string
  # Returns integers as a string with the given delimiter.
  def to_dec_stream(delim=",")
    self.extract_ary().join(delim)
  end
    
  def dec_to_ascii
    self.scan(DECINTREGEX).map { |x| x.to_i.chr }.join().force_encoding(Encoding::ASCII_8BIT)
  end
  
  # Renders the given string or array into a hex-editor-like representation.
  def to_hexed
    
    data = self.extract_ary
  
    output = "="*75
  
    for i in (0..data.length-1).step(16)
        output += "\n%05d  " % i
        for j in (0..15)
            if i+j < data.length
                output += "%02X " % data[i+j]
            else
                output += "   "
            end
            if j == 7
                output += " "
            end
        end
  
        output += " "
  
        for j in (0..15)
            if i+j < data.length
                ch = data[i+j]
                if ch >= 32 and ch < 127
                    output += "%c" % ch
                else
                    output += "."
                end
            else
                output += " "
            end
            if j == 7
                output += "  "
            end
        end
    end
    output += "\nLength = %05d " % data.length + "="*60 + "\n"
  end
  
  # Delimit contents with the given grouping and delimiter.
  def delimit(grouping=2, delim=' ')
    self.scan(/#{'.'*grouping}/).join(delim)
  end
  
  # strip all whitespace from string
  def stripall
    self.split().join()
  end
  
  # Converts this string to syntax highlighted html using Python pygments
  # http://pygments.org/
  # Pygments installation: http://pygments.org/docs/installation/
  #   (usually 'sudo easy_install Pygments')
  # Call 'pygmentize -L' for list of available lexers
  # To generate the CSS for the generated HTML: 'pygmentize -S default -f html'
  def pygmentize(lexer)
    pygmentize = IO.popen("pygmentize -S default -f html -l #{lexer}", "w+") 
    pygmentize.puts self
    pygmentize.close_write 
    result = pygmentize.gets(nil)
    pygmentize.close
    result
  end
  
end

# Make our tools available through the String class
class String
  include StringTools
end


if $0 == __FILE__
  require 'test/unit'

  class StringToolsTest < Test::Unit::TestCase
    
    def test_ishex?
      assert("23 d3 ad 32".is_hex?)
    end
    
    def test_extract_ary
      assert_equal([72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100], "48,65,6C,6C,6F,20,57,6F,72,6C,64".extract_ary)
      assert_equal([72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100], "48 65 6C 6C 6F 20 57 6F 72 6C 64".extract_ary)
      assert_equal([324, 6578, 976, 23], "324, 6578, 976, 23".extract_ary)
      assert_equal([192, 168, 0, 1], "192.168.0.1".extract_ary)
    end
    
    def test_find_hex_bytes
      assert_equal("48 65 6C 6C 6F 20 57 6F 72 6C 64", "00000  48 65 6C 6C 6F 20 57 6F  72 6C 64                 Hello Wo  rld     \nLength = 00011\n".find_hex_bytes)
    end

    # def test_stringWithHexStream
    #   assert_equal(HexTools.stringWithHexStream("48656C6C6F20576F726C64"), "Hello World")
    #   assert_equal(HexTools.stringWithHexStream("48, 65, 6C,6C,6F,20,57,6F,72,6C,64"), "Hello World")
    #   assert_equal(HexTools.stringWithHexStream("48 65 6C 6C 6F 20 57 6F 72 6C 64"), "Hello World")
    # end
    # 
    # def test_aryWithHexStream
    #   assert_equal(HexTools.aryWithHexStream("48656C6C6F20576F726C64"), [72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100])
    #   assert_equal(HexTools.aryWithHexStream("48,65,6C,6C,6F,20,57,6F,72,6C,64"), [72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100])
    #   assert_equal(HexTools.aryWithHexStream("48 65 6C 6C 6F 20 57 6F 72 6C 64"), [72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100])
    # end
    # 
    # def test_hexStreamWithString
    #   assert_equal(HexTools.hexStreamWithString("Hello World"), "48 65 6C 6C 6F 20 57 6F 72 6C 64")
    #   assert_equal(HexTools.hexStreamWithString("Hello World", ","), "48,65,6C,6C,6F,20,57,6F,72,6C,64")
    # end
    # 
    # def test_hexEditorFormatWithData
    #   assert_equal(HexTools.hexEditorFormatWithData("Hello World"), "===========================================================================\n" +
    #                                                                 "00000  48 65 6C 6C 6F 20 57 6F  72 6C 64                 Hello Wo  rld     \n" +
    #                                                                 "Length = 00011 ============================================================\n")
    #   assert_equal(HexTools.hexEditorFormatWithData([72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100]), "===========================================================================\n" +
    #                                                                                                        "00000  48 65 6C 6C 6F 20 57 6F  72 6C 64                 Hello Wo  rld     \n" +
    #                                                                                                        "Length = 00011 ============================================================\n")
    # end
    # 
    # def test_hexStreamWithHexByteString
    #   assert_equal(HexTools.hexStreamWithHexByteString("===========================================================================\n00000  48 65 6C 6C 6F 20 57 6F  72 6C 64                 Hello Wo  rld     \nLength = 00011 ============================================================\n"), "48 65 6C 6C 6F 20 57 6F 72 6C 64")  
    # end
    # 
    # def test_hexStreamSetDelimiter
    #   assert_equal(HexTools.hexStreamSetDelimiter("48656C6C6F20576F726C64"), "48,65,6C,6C,6F,20,57,6F,72,6C,64")
    #   assert_equal(HexTools.hexStreamSetDelimiter("48656C6C6F20576F726C64", " "), "48 65 6C 6C 6F 20 57 6F 72 6C 64")
    #   assert_equal(HexTools.hexStreamSetDelimiter("48,65,6C,6C,6F,20,57,6F,72,6C,64", ""), "48656C6C6F20576F726C64")
    # end
    # 
    # def test_intWithHexStream
    #   assert_equal(HexTools.intWithHexStream("48656C6C6F20576F726C64"), "72,101,108,108,111,32,87,111,114,108,100")
    # end
    # 
    # def test_hexStreamWithDecStream
    #   assert_equal(HexTools.hexStreamWithDecStream("14392.186.3,2,  3"), "3838 BA 3 2 3")
    #   assert_equal(HexTools.hexStreamWithDecStream("14392.186.3,2", ", "), "3838, BA, 3, 2")
    # end
    # 
    # def test_hexStreamWithAry
    #   assert_equal(HexTools.hexStreamWithAry([72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100]), "48 65 6C 6C 6F 20 57 6F 72 6C 64")
    # end
  end
end