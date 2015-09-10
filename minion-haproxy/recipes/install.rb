# put the credential
private_ip = node['opsworks']['instance']['private_ip']
hostname = node['opsworks']['instance']['hostname']
instances = Array.new

node['opsworks']['layers']['kub-minion']['instances'].each do |inst|
	instances << inst[0]  + " " + inst[1][:private_ip]
end

template "/root/haproxy" do
  source "haproxy.erb"
  variables({
	:instances => instances
  })
end