require "net/http"
require "uri"
require "benchmark"

auth_token = "FOOFOO"
url = "http://tf.dev.mirerca.com/worlds/2/megatiles.FORMAT?x_min=400&y_min=400&x_max=420&y_max=420&auth_token=#{auth_token}"


puts "JSON"
bm = Benchmark.measure do
  uri = URI.parse(url.sub("FORMAT", "json"))
  100.times do
    Net::HTTP.get_response uri
  end
end
puts bm

puts "XML"
bm = Benchmark.measure do
  uri = URI.parse(url.sub("FORMAT", "xml"))
  100.times do 
    Net::HTTP.get_response uri
  end
end
puts bm

puts "MessagePack:"
bm = Benchmark.measure do
  uri = URI.parse(url.sub("FORMAT", "mpac"))
  100.times do 
    Net::HTTP.get_response uri
  end
end
puts bm
