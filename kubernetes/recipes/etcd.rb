bash 'install_etcd' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
  wget https://github.com/coreos/etcd/releases/download/v2.1.0-rc.0/etcd-v2.1.0-rc.0-linux-amd64.tar.gz
  tar zxvf etcd-v2.1.0-rc.0-linux-amd64.tar.gz
  cd etcd-v2.1.0-rc.0-linux-amd64
  cp etcd etcdctl /usr/local/bin
  EOH
end


template "/etc/init.d/etcd" do
	mode "0755"
	owner "root"
	source "etcd.erb"
end


service "etcd" do
	action [:enable, :start]
	subscribes :reload, "template[/etc/init.d/etcd]", :immediately
	notifies :run, "bash[ba_setup]", :delayed
end

bash 'ba_setup' do
	user 'root'
	cwd '/tmp'
	code <<-EOH
	curl -X PUT -d "{\"user\":\"root\",\"password\":\"#{node['etcd_password']}\",\"roles\":[\"root\"]}" http://localhost:4001/v2/auth/users/root > ba_log
	curl -X PUT http://localhost:4001/v2/auth/enable >> ba_log
	AUTHSTR=$(echo -n "root:#{node['etcd_password']}" | base64)
	curl -H "Authorization: Basic $AUTHSTR" -X PUT -d "{\"role\":\"guest\",\"revoke\":{\"kv\":{\"read\":[\"*\"],\"write\":[\"*\"]}}}" http://localhost:4001/v2/auth/roles/guest >> ba_log
	EOH
	action :nothing
end


