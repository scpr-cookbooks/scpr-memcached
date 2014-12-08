include_recipe "scpr-memcached"

scpr_memcached "test" do
  action  :create
  memory  128
  port    12345
end