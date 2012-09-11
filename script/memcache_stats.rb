require 'socket'

socket = TCPSocket.open('localhost', '11211')
socket.send("stats\r\n", 0)

statistics = []
loop do
  data = socket.recv(4096)
  if !data || data.length == 0
    break
  end
  statistics << data
  if statistics.join.split(/\n/)[-1] =~ /END/
    break
  end
end

puts statistics.join()
