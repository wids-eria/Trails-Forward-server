require "net/http"
require "uri"
require "benchmark"

mpac_uri = URI.parse("http://localhost:3000/worlds/1/megatiles.mpac?auth_token=xxjfRu0xEH74ofeHhPP0")
json_uri = URI.parse("http://localhost:3000/worlds/1/megatiles.json?auth_token=xxjfRu0xEH74ofeHhPP0")
xml_uri = URI.parse("http://localhost:3000/worlds/1/megatiles.xml?auth_token=xxjfRu0xEH74ofeHhPP0")

puts "MessagePack:"
Benchmark.measure { 100.times {Net::HTTP.get_response mpac_uri} }

puts "JSON"
Benchmark.measure { 100.times {Net::HTTP.get_response json_uri} }

puts "XML"
Benchmark.measure { 100.times {Net::HTTP.get_response xml_uri} }
