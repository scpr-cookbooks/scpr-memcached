action :create do
  svc_name = "memcached-#{new_resource.name}"

  # what ip are we listening on?
  listen_ip = node.network.interfaces[ node.scpr_memcached.listen_interface ].addresses.find { |k,v|
    v.family == "inet"
  }.first

  # -- create crappy restart sequence to enable upstart config reloads -- #

  need_stop_start = false
  if ::File.exists?("/etc/init/#{svc_name}.conf")
    need_stop_start = true

    service "#{svc_name}-stop" do
      service_name  svc_name
      provider      Chef::Provider::Service::Upstart
      action        :nothing
      supports      [:stop]
      notifies      :start, "service[#{svc_name}-start]", :immediately
    end

    service "#{svc_name}-start" do
      service_name  svc_name
      provider      Chef::Provider::Service::Upstart
      action        :nothing
      supports      [:start]
    end

  end

  # -- Write our upstart config -- #

  service svc_name do
    provider  Chef::Provider::Service::Upstart
    action    :nothing
    supports  [:enable,:start,:stop,:restart]
  end

  template "/etc/init/#{svc_name}.conf" do
    cookbook  "scpr-memcached"
    source    "upstart.conf.erb"
    mode      0644
    variables({
      service:    new_resource,
      listen_ip:  listen_ip,
    })
    notifies :stop,   "service[#{svc_name}-stop]" if need_stop_start
    notifies :start,  "service[#{svc_name}]"
  end
end

action :delete do

end