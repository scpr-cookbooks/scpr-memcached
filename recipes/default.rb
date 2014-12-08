#
# Cookbook Name:: scpr-memcached
# Recipe:: default
#
# Copyright (c) 2014 Southern California Public Radio, All Rights Reserved.

include_recipe "apt"

# Make sure consul is set up
include_recipe "scpr-consul"

# Disable the default memcache service
file "/etc/default/memcached" do
  action :create
  content "ENABLE_MEMCACHED=no"
end

execute "remove-memcached-from-sysv" do
  action :nothing
  command "/usr/sbin/update-rc.d memcached remove"
end

file "/etc/init.d/memcached" do
  action :nothing
  notifies :run, "execute[remove-memcached-from-sysv]"
end

# Install memcache
package "memcached" do
  options '-o Dpkg::Options::="--force-confold"'
  notifies :delete, "file[/etc/init.d/memcached]"
end

package "libmemcached-dev"


# -- Are there any attribute-defined instances? -- #

(node.scpr_memcached.instances||[]).each do |k,opts|
  scpr_memcached k do
    action  :create
    memory  opts["memory"]
    port    opts["port"]
  end
end

