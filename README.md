# ConsulMutEx

_An Elixir module for acquiring and releasing locks with Consul and other backends._


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `consul_mut_ex` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:consul_mut_ex, "~> 0.1.0"}]
    end
    ```

  2. Ensure `consul_mut_ex` is started before your application:

    ```elixir
    def application do
      [applications: [:consul_mut_ex]]
    end
    ```


## Usage

Setup the default backend ([ETS](http://erlang.org/doc/man/ets.html)):

```elixir
iex> Application.put_env(:consul_mut_ex, :backend, :ets)
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

## Testing

```elixir
mix test
```


## Coming Soon

 * __Consul as a backend__
 * __Polling__


## History

  * `v0.1.0` - Initial lock code works with ETS backend.


## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D
