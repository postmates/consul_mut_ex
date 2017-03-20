# ConsulMutEx

_An Elixir module for acquiring and releasing locks with Consul and other backends._


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `consul_mut_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:consul_mut_ex, "~> 1.0.0"}]
end
```

  2. Ensure `consul_mut_ex` is started before your application:

```elixir
def application do
  [applications: [:consul_mut_ex]]
end
```


## Usage

```elixir
iex> require ConsulMutEx
```

Add to config.exs:

```elixir
config :consul_mut_ex, :backend, :consul
config :consul_mut_ex, :consul,
  host: "http://localhost:8500"
```

or through environment vars:

```elixir
config :consul_mut_ex, :consul,
  host: { :system, "CONSUL_HOST" }
```

Pass in a `do...else` block:

```elixir
iex> ConsulMutEx.lock("test_key", max_retries: 0) do
...>   :acquired
...> else
...>   :failed_to_acquire
...> end
:acquired
```

Or, call `acquire_lock` and `release_lock` manually:

```elixir
iex> {:ok, lock} = ConsulMutEx.acquire_lock("test_key", max_retries: 0)
iex> ConsulMutEx.lock("test_key", max_retries: 0) do
...>   :acquired
...> else
...>   :failed_to_acquire
...> end
:failed_to_acquire
iex> ConsulMutEx.release_lock(lock)
:ok
```

## Local development

Install consul
```sh
$ brew install consul
$ brew services start consul
==> Successfully started `consul` (label: homebrew.mxcl.consul)
```

Test consul works
```sh
$ curl -X GET "http://localhost:8500/v1/status/leader"
"127.0.0.1:8300"
```

Test you can obtain the lock
```elixir
iex> require ConsulMutEx
iex> {:ok, lock} = ConsulMutEx.acquire_lock("test_key", max_retries: 0)
```

## Testing

```sh
mix test
```


## Documentation

```sh
mix docs
open docs/index.html
```


## History

  * `v0.1.0` - Initial lock code works with ETS backend.
  * `v0.2.0` - Supporting Consul as a backend.
  * `v1.0.0` - Open source release


## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D
