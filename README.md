# Ruby Key-Value Store

Just a simple key-value database I built in Ruby for fun. Based on the Bitcask model.

## What it does

- Stores key-value pairs to disk
- Pretty fast lookups with an in-memory index
- Supports strings, numbers, and floats

## Try it out

```ruby
require_relative "lib/bitcask/disk_store"

store = Bitcask::DiskStore.new
store.put("name", "Sai'd")
store.put("age", 25)

puts store.get("name")  # => "Sai'd"
puts store.get("age")   # => 25
```

Try it:
```bash
ruby main.rb
```

## How it works

- Everything gets saved to a binary file (`bitcask.db`)
- Keeps an index in memory so lookups are quick
- Uses checksums to make sure data isn't corrupted
- Just appends new stuff to the end (keeps it simple)

## What's in here

- `lib/bitcask/serializer.rb` - handles the binary encoding
- `lib/bitcask/disk_store.rb` - the main database part
- `main.rb` - example to mess play with


It's just a learning project, so there's no:
- Compaction (the file just keeps growing)
- Way to delete keys
- Fancy error recovery

it works and taught me some cool stuff about how databases work tho!
