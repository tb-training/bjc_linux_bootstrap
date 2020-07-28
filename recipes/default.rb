#
# Cookbook:: bjc_linux_bootstrap
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
bash 'Do some chef pre-work' do
    code <<-EOH

#!/bin/bash -xev
/bin/mkdir -p /etc/chef
/bin/mkdir -p /var/lib/chef
/bin/mkdir -p /var/log/chef

EOH
end

bash 'Setup hosts file correctly' do
    code <<-EOH
cat > "/etc/hosts" << EOF
172.31.54.57 chef.automate-demo.com
172.31.54.22 automate.automate-demo.com
EOF

EOH
end

bash 'Install chef' do
    code <<-EOH
cd /etc/chef/

#do not install chef-client again
#curl -L https://omnitruck.chef.io/install.sh | bash || error_exit 'could not install chef'

# Create first-boot.json
cat > "/etc/chef/first-boot.json" << EOF
{
   "run_list" :[
   "role[base]"
   ]
}
EOF

EOH
end

bash 'Create client.rb' do
    code <<-EOH

NODE_NAME=rhel-YOURNAME-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 4 | head -n 1)

/bin/echo 'log_location     STDOUT' > /etc/chef/client.rb
/bin/echo -e "chef_server_url 'https://chef.automate-demo.com/organizations/automate-org'" >> /etc/chef/client.rb
/bin/echo -e "validation_client_name 'automate-org-validator'" >> /etc/chef/client.rb
/bin/echo -e "validation_key '/tmp/kitchen/cookbooks/bjc_linux_bootstrap/recipes/automate_org_validator.pem'" >> /etc/chef/client.rb
/bin/echo -e "node_name '${NODE_NAME}'" >> /etc/chef/client.rb
/bin/echo -e "ssl_verify_mode :verify_none" >> /etc/chef/client.rb
EOH
end

bash 'Run It' do
    code <<-EOH

sudo chef-client -j /etc/chef/first-boot.json

EOH
end
