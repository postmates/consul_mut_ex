defmodule ConsulMutEx.Backends.ETSBackend do
  @moduledoc """
  Use Erlang's built-in storage to create and release locks.
  This backend will create a lock per node, not per cluster.

  [ETS documentation](http://erlang.org/doc/man/ets.html)
  """

  @table :consul_mut_ex_locks
  @timeout 1000

  @doc """
  Initialize this backend. This must be called before this backend is used.
  """
  @spec init() :: :ok
  def init() do
    :ets.new(@table, [:set, :named_table, :public])
    :ok
  end

  @doc """
  Acquire a lock.

  ## Arguments:

    * `key`: A key to identify the lock
    * `opts`: Options
      * `max_retries`: Maximum number of retries, defaults to 0.
      * `cooldown`: Milliseconds to sleep between retries, defaults to 1000.
  """
  @spec acquire_lock(String.t, keyword()) :: {:ok, Lock.t} | :error
  def acquire_lock(key, opts \\ []) do
    do_acquire_lock(key, opts, 0)
  end

  defp do_acquire_lock(key, opts, retries) do
    session = make_ref()
    if :ets.insert_new(@table, {key, session}) do
      {:ok, new_lock(key, session)}
    else
      if retries < Keyword.get(opts, :max_retries, 0) do
        :timer.sleep(Keyword.get(opts, :cooldown, @timeout))
        do_acquire_lock(key, opts, retries + 1)
      else
        :error
      end
    end
  end

  @doc """
  Release a lock.
  """
  @spec release_lock(Lock.t, keyword()) :: :ok
  def release_lock(lock, opts \\ []) do
     :ets.delete(@table, lock.key)

     :ok
  end

  @doc """
  Verify a lock.
  """
  @spec verify_lock(Lock.t) :: :ok | {:error, any()}
  def verify_lock(lock) do
    key = lock.key
    session = lock.session

    case :ets.lookup(@table, key) do
      [{^key, ^session}] -> :ok # we own it
      [{^key, other_session}] -> {:error, other_session} # someone else owns it
      [] -> {:error, nil} # no one owns it
    end
  end

  defp new_lock(key, session) do
    %ConsulMutEx.Lock{key: key, owner: self(), session: session}
  end
end
