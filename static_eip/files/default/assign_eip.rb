require 'ipaddr'

available_ips = ARGV[0].split(',').map { |x| IPAddr.new(x) }
valid_ips = ARGV[1].split(',').map { |x| IPAddr.new(x) }
invalid_ips = ARGV[2].to_s.split(',').map { |x| IPAddr.new(x) }

available_ip = available_ips.shuffle.find do |ip|
  valid_ips.any? { |y| y.include?(ip) } && !invalid_ips.include?(ip)
end

puts available_ip.to_s
