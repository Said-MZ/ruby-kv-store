require_relative "lib/bitcask/disk_store"

store = Bitcask::DiskStore.new
store.put("name", "Sai'd")
store.put("lang", "Ruby")

puts store.get("name")  # => Sai'd
puts store.get("lang")  # => Ruby
