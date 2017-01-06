defmodule ConsulMutEx.Backends.ETSBackend do

  @table :consul_mut_ex_locks
  @timeout 1000

  @doc """
  Initialize this backend.

  Note: this must be called before this backend is used.
  TODO: How should this be called by people using this library? Probably in our application start function,
  based on the config!
  """
  @spec init() :: :ok
  def init() do
    :ets.new(@table, [:set, :named_table, :public])
    :ok
  end

  @doc """
  Acquire a lock.

  ## Arguments:

    * `key`: A key
    * `opts`: Options
      * `max_retries`: Maximum number of retries, defaults to 0.
      * `cooldown`: Milliseconds to sleep between retries, defaults to 1000.
  """
  @spec acquire_lock(String.t, keyword()) :: {:ok, Lock.t} | :error
  def acquire_lock(key, opts \\ []) do
    do_acquire_lock(key, opts, 0)
  end

  defp do_acquire_lock(key, opts, retries) do
    if :ets.insert_new(@table, {key, self()}) do
      {:ok, new_lock(key)}
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
  @spec release_lock(Lock.t) :: :ok
  def release_lock(lock) do
     :ets.delete(@table, lock.key)
     :ok
  end

  defp new_lock(key) do
    %ConsulMutEx.Lock{key: key, owner: self()}
  end
end
