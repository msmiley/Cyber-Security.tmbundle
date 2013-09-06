#!/usr/bin/env ruby

require 'openssl'

module RSATools

  # regex matches RSA private or public in PEM/base64 PKCS#1 format
  RSAREGEX = /-----BEGIN RSA (?:PRIVATE|PUBLIC) KEY-----\s{0,2}([A-Za-z0-9+\/\s{0,2}]{4})*([A-Za-z0-9+\/]{3}=|[A-Za-z0-9+\/]{2}==)?\s{0,2}-----END RSA (?:PRIVATE|PUBLIC) KEY-----/

  # convert PEM key to DER key in string form 
  def self.getDERWithPEM(pem)
    k = OpenSSL::PKey::RSA.new pem
    k.to_der
  end

  # return formatted string with to_text of key
  def self.getTextWithPEM(pem)
    k = OpenSSL::PKey::RSA.new pem
    k.to_text
  end

end

if $0 == __FILE__
  include RSATools
  require 'test/unit'

  class RSAToolsTest < Test::Unit::TestCase
    
    @@example_priv_key = "-----BEGIN RSA PRIVATE KEY-----\nMIICWgIBAAKBgHx5XHa3LjiugtNq2xkd0oFf2SdsJ04hQYLoeRR3bqAei3Gc+PSy\nAvynCIh/03JCvBsUHaCe8BwjwaTYrpq5QunGo/wvIzvx2d3G9dlrpOIFLiatZYOf\nh07+CkSfaRXhBUKkul/gU87WPhKEcbnPDJS10uD1HqLsHfSKLNitGOf7AgElAoGA\nENIhQHmedlzFkjEI2eFveURNxw6dhxlANEjtxH7XmRjiaUyQWGsVKQ+nNQpa2Bbb\nJkD9FbSc/OI8wz/gPmwP9eJN29CriebhaV3ebM1L1gbb5r7Vf/D/6rxB0BG/h2lA\njyZWEZrV/Gi9ZCaw/J+IUu1pAskKid84yHphvszywCUCQQDigrtr+cVkwkUsxOGd\nB378yQCroXmybAD7FQHwVslafuFfTHkaMQSU/ZZLVY1ioMs1VVzzq/vOu0RstZOY\nAfHFAkEAjK3mIWdG4JOM44/SrDkACNatsMtXKOi4K3SlXu9ie6ikXPD+GSZ+bWCX\nGstFaXr9cHRvZPF3qYtK+j2N9UXOvwJBALeoRO/DmSFDkgifoixLRF5CHDgiD6Vs\nU9J/vGIBLaNSHoSe3rtKVr3+CyhTNF3Oe0AABi1bA4UGioGn+yFNr0UCQBbQF3sJ\n1CRq9ECT3PlVWfOYbzFtFQ2NhaYul1uAw9yzkEZsROF73SZ+XbFRZTOzFFds08su\nE2eaDCiUXDWcnhECQQCRUQn2huHlssj8kt35NAVwiHCNfaeSQ5tiDcwfOywA4YXl\nQ+kpuWq5U3V8j/9/n7pE/DL0nXEG/3QpKHJEYV5T\n-----END RSA PRIVATE KEY-----\n"
    
    def test_getDERWithPEM
      assert_equal(RSATools.getDERWithPEM(@@example_priv_key), "0\x82\x02Z\x02\x01\x00\x02\x81\x80|y\\v\xB7.8\xAE\x82\xD3j\xDB\x19\x1D\xD2\x81_\xD9'l'N!A\x82\xE8y\x14wn\xA0\x1E\x8Bq\x9C\xF8\xF4\xB2\x02\xFC\xA7\b\x88\x7F\xD3rB\xBC\e\x14\x1D\xA0\x9E\xF0\x1C#\xC1\xA4\xD8\xAE\x9A\xB9B\xE9\xC6\xA3\xFC/#;\xF1\xD9\xDD\xC6\xF5\xD9k\xA4\xE2\x05.&\xADe\x83\x9F\x87N\xFE\nD\x9Fi\x15\xE1\x05B\xA4\xBA_\xE0S\xCE\xD6>\x12\x84q\xB9\xCF\f\x94\xB5\xD2\xE0\xF5\x1E\xA2\xEC\x1D\xF4\x8A,\xD8\xAD\x18\xE7\xFB\x02\x01%\x02\x81\x80\x10\xD2!@y\x9Ev\\\xC5\x921\b\xD9\xE1oyDM\xC7\x0E\x9D\x87\x19@4H\xED\xC4~\xD7\x99\x18\xE2iL\x90Xk\x15)\x0F\xA75\nZ\xD8\x16\xDB&@\xFD\x15\xB4\x9C\xFC\xE2<\xC3?\xE0>l\x0F\xF5\xE2M\xDB\xD0\xAB\x89\xE6\xE1i]\xDEl\xCDK\xD6\x06\xDB\xE6\xBE\xD5\x7F\xF0\xFF\xEA\xBCA\xD0\x11\xBF\x87i@\x8F&V\x11\x9A\xD5\xFCh\xBDd&\xB0\xFC\x9F\x88R\xEDi\x02\xC9\n\x89\xDF8\xC8za\xBE\xCC\xF2\xC0%\x02A\x00\xE2\x82\xBBk\xF9\xC5d\xC2E,\xC4\xE1\x9D\a~\xFC\xC9\x00\xAB\xA1y\xB2l\x00\xFB\x15\x01\xF0V\xC9Z~\xE1_Ly\x1A1\x04\x94\xFD\x96KU\x8Db\xA0\xCB5U\\\xF3\xAB\xFB\xCE\xBBDl\xB5\x93\x98\x01\xF1\xC5\x02A\x00\x8C\xAD\xE6!gF\xE0\x93\x8C\xE3\x8F\xD2\xAC9\x00\b\xD6\xAD\xB0\xCBW(\xE8\xB8+t\xA5^\xEFb{\xA8\xA4\\\xF0\xFE\x19&~m`\x97\x1A\xCBEiz\xFDptod\xF1w\xA9\x8BJ\xFA=\x8D\xF5E\xCE\xBF\x02A\x00\xB7\xA8D\xEF\xC3\x99!C\x92\b\x9F\xA2,KD^B\x1C8\"\x0F\xA5lS\xD2\x7F\xBCb\x01-\xA3R\x1E\x84\x9E\xDE\xBBJV\xBD\xFE\v(S4]\xCE{@\x00\x06-[\x03\x85\x06\x8A\x81\xA7\xFB!M\xAFE\x02@\x16\xD0\x17{\t\xD4$j\xF4@\x93\xDC\xF9UY\xF3\x98o1m\x15\r\x8D\x85\xA6.\x97[\x80\xC3\xDC\xB3\x90FlD\xE1{\xDD&~]\xB1Qe3\xB3\x14Wl\xD3\xCB.\x13g\x9A\f(\x94\\5\x9C\x9E\x11\x02A\x00\x91Q\t\xF6\x86\xE1\xE5\xB2\xC8\xFC\x92\xDD\xF94\x05p\x88p\x8D}\xA7\x92C\x9Bb\r\xCC\x1F;,\x00\xE1\x85\xE5C\xE9)\xB9j\xB9Su|\x8F\xFF\x7F\x9F\xBAD\xFC2\xF4\x9Dq\x06\xFFt)(rDa^S".force_encoding(Encoding::ASCII_8BIT))
    end
    
    def test_getTextWithPEM
      assert_equal(RSATools.getTextWithPEM(@@example_priv_key), "Private-Key: (1023 bit)\nmodulus:\n    7c:79:5c:76:b7:2e:38:ae:82:d3:6a:db:19:1d:d2:\n    81:5f:d9:27:6c:27:4e:21:41:82:e8:79:14:77:6e:\n    a0:1e:8b:71:9c:f8:f4:b2:02:fc:a7:08:88:7f:d3:\n    72:42:bc:1b:14:1d:a0:9e:f0:1c:23:c1:a4:d8:ae:\n    9a:b9:42:e9:c6:a3:fc:2f:23:3b:f1:d9:dd:c6:f5:\n    d9:6b:a4:e2:05:2e:26:ad:65:83:9f:87:4e:fe:0a:\n    44:9f:69:15:e1:05:42:a4:ba:5f:e0:53:ce:d6:3e:\n    12:84:71:b9:cf:0c:94:b5:d2:e0:f5:1e:a2:ec:1d:\n    f4:8a:2c:d8:ad:18:e7:fb\npublicExponent: 37 (0x25)\nprivateExponent:\n    10:d2:21:40:79:9e:76:5c:c5:92:31:08:d9:e1:6f:\n    79:44:4d:c7:0e:9d:87:19:40:34:48:ed:c4:7e:d7:\n    99:18:e2:69:4c:90:58:6b:15:29:0f:a7:35:0a:5a:\n    d8:16:db:26:40:fd:15:b4:9c:fc:e2:3c:c3:3f:e0:\n    3e:6c:0f:f5:e2:4d:db:d0:ab:89:e6:e1:69:5d:de:\n    6c:cd:4b:d6:06:db:e6:be:d5:7f:f0:ff:ea:bc:41:\n    d0:11:bf:87:69:40:8f:26:56:11:9a:d5:fc:68:bd:\n    64:26:b0:fc:9f:88:52:ed:69:02:c9:0a:89:df:38:\n    c8:7a:61:be:cc:f2:c0:25\nprime1:\n    00:e2:82:bb:6b:f9:c5:64:c2:45:2c:c4:e1:9d:07:\n    7e:fc:c9:00:ab:a1:79:b2:6c:00:fb:15:01:f0:56:\n    c9:5a:7e:e1:5f:4c:79:1a:31:04:94:fd:96:4b:55:\n    8d:62:a0:cb:35:55:5c:f3:ab:fb:ce:bb:44:6c:b5:\n    93:98:01:f1:c5\nprime2:\n    00:8c:ad:e6:21:67:46:e0:93:8c:e3:8f:d2:ac:39:\n    00:08:d6:ad:b0:cb:57:28:e8:b8:2b:74:a5:5e:ef:\n    62:7b:a8:a4:5c:f0:fe:19:26:7e:6d:60:97:1a:cb:\n    45:69:7a:fd:70:74:6f:64:f1:77:a9:8b:4a:fa:3d:\n    8d:f5:45:ce:bf\nexponent1:\n    00:b7:a8:44:ef:c3:99:21:43:92:08:9f:a2:2c:4b:\n    44:5e:42:1c:38:22:0f:a5:6c:53:d2:7f:bc:62:01:\n    2d:a3:52:1e:84:9e:de:bb:4a:56:bd:fe:0b:28:53:\n    34:5d:ce:7b:40:00:06:2d:5b:03:85:06:8a:81:a7:\n    fb:21:4d:af:45\nexponent2:\n    16:d0:17:7b:09:d4:24:6a:f4:40:93:dc:f9:55:59:\n    f3:98:6f:31:6d:15:0d:8d:85:a6:2e:97:5b:80:c3:\n    dc:b3:90:46:6c:44:e1:7b:dd:26:7e:5d:b1:51:65:\n    33:b3:14:57:6c:d3:cb:2e:13:67:9a:0c:28:94:5c:\n    35:9c:9e:11\ncoefficient:\n    00:91:51:09:f6:86:e1:e5:b2:c8:fc:92:dd:f9:34:\n    05:70:88:70:8d:7d:a7:92:43:9b:62:0d:cc:1f:3b:\n    2c:00:e1:85:e5:43:e9:29:b9:6a:b9:53:75:7c:8f:\n    ff:7f:9f:ba:44:fc:32:f4:9d:71:06:ff:74:29:28:\n    72:44:61:5e:53\n")
    end
  end
end
