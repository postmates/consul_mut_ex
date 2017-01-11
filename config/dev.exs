use Mix.Config

# NOTE: Set Consul as default backend
config :consul_mut_ex, :backend, :consul

config :consul_mut_ex, :consul,
  host: { "http://localhost:8500" }
