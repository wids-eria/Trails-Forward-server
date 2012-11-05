
puts "here we go!!!"
contract = Contract.find 3
matcher = YoungdaeTileMatcher.new
ret = matcher.find_and_attach_to_contract_with_player contract

puts "Return status: #{ret}"

