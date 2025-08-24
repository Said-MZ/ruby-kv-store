require "zlib" # for CRC32 checksums

module Bitcask
  module Serializer
    # Header format:
    # L< = 4-byte unsigned little-endian integer
    # S< = 2-byte unsigned little-endian integer
    HEADER_FORMAT = "L<L<L<S<S<" # 4+4+4+2+2 = 16 bytes
    HEADER_SIZE   = 16

    CRC32_FORMAT  = "L<"         # 4 bytes
    CRC32_SIZE   = 4


    DATA_TYPE = {
      String: 1,
      Integer: 2,
      Float: 3
    }.freeze

    DATA_TYPE_LOOKUP = {
      1 => :String,
      2 => :Integer,
      3 => :Float
    }.freeze

    def serialize(epoch:, key:, value:)
      key_bytes   = encode key
      value_bytes = encode value

      header = [epoch, key_bytes.size, value_bytes.size,
                DATA_TYPE[key.class.to_s.to_sym],
                DATA_TYPE[value.class.to_s.to_sym]].pack(HEADER_FORMAT)

      data = key_bytes + value_bytes

      crc = [Zlib.crc32(header + data)].pack(CRC32_FORMAT)
      
      [crc + header + data, crc.bytesize, header.bytesize, data.bytesize]
    end

    def deserialize(record)
      stored_crc      = record[0...CRC32_SIZE].unpack1(CRC32_FORMAT)
      rest            = record[CRC32_SIZE..]
      calc_crc        = Zlib.crc32(rest)

      return nil if stored_crc != calc_crc

      epoch, keysz, valuesz, key_type, val_type =
        rest[0...HEADER_SIZE].unpack(HEADER_FORMAT)

      key   = decode(rest[HEADER_SIZE, keysz], DATA_TYPE_LOOKUP[key_type])
      value = decode(rest[HEADER_SIZE + keysz, valuesz], DATA_TYPE_LOOKUP[val_type])

      { epoch: epoch, key: key, value: value }
    end

    private

    def encode(obj)
       case obj
        when String  then obj.encode("utf-8")
        when Integer then [obj].pack("q<")   # 8-byte signed int
        when Float   then [obj].pack("E")    # double precision float
        else
          raise "Unsupported type: #{obj.class}"
       end
    end

    def decode(bytes, type)
      case type
      when :String  then bytes.force_encoding("utf-8")
      when :Integer then bytes.unpack1("q<")
      when :Float   then bytes.unpack1("E")
      else
        raise "Unsupported type: #{type}"
      end
    end
  end
end