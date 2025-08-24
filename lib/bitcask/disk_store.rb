require_relative "serializer"

module Bitcask
  class DiskStore
    include Serializer

    def initialize(db_file = 'bitcask.db')
      @db_fh = File.open(db_file, 'a+b')
      @write_pos = 0
      @key_dir = {}
    end

    def put(key, value)
      epoch = Time.now.to_i
      record, size = serialize(epoch:, key:, value:)

      @key_dir[key] = key_struct(@write_pos, size, key)
      persist(record)
      incr_write_pos(size)

      nil
    end

    def get(key)
      key_info = @key_dir[key]
      return nil unless key_info

      @db_fh.seek(key_info[:write_pos])
      raw = @db_fh.read(key_info[:log_size])
      deserialize(raw)[:value]
    end

    def flush
      @db_fh.flush
    end

    private

    def persist(data)
      @db_fh.write(data)
      @db_fh.flush
    end

    def incr_write_pos(pos)
      @write_pos += pos
    end

    def key_struct(write_pos, log_size, key)
      { write_pos:, log_size:, key: }
    end
  end
end
