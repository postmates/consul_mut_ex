defmodule ConsulMutEx do
  @moduledoc """

  TODO: Add polling mechanism to "refresh" lock

  Examples:

      iex> Application.put_env(:consul_mut_ex, :backend, :ets)
      iex> ConsulMutEx.lock("test_key", timeout: 0) do
      ...>   :acquired
      ...> else
      ...>   :failed_to_acquire
      ...> end
      :acquired
      iex> lock = ConsulMutEx.acquire_lock("test_key", timeout: 0)
      iex> ConsulMutEx.lock("test_key", timeout: 0) do
      ...>   :acquired
      ...> else
      ...>   :failed_to_acquire
      ...> end
      :failed_to_acquire
      iex> ConsulMutEx.release_lock(lock)
      :ok
  """

  alias ConsulMutEx.Lock

  @doc """
  Acquire a lock
  """
  @spec acquire_lock(String.t, keyword()) :: {:ok, Lock.t} | :error
  def acquire_lock(key, opts \\ []) do
     get_backend().acquire_lock(key, opts)
  end

  @doc """
  Release a lock
  """
  @spec release_lock(Lock.t) :: :ok
  def release_lock(lock) do
     get_backend().release_lock(lock)
  end

  @doc """
  Lock and run a code block
  """
  @spec lock(String.t, keyword(), keyword()) :: any()
  def lock(key, opts \\ [], block) do
    case acquire_lock(key, opts) do
      {:ok, lock} ->
        try do
          # Acquired the lock
          block[:do].()
        after
          # Release the lock
          release_lock(lock)
        end
      :error ->
        case block[:else] do
          nil -> nil
          els -> els.()
        end
    end
  end

  defp get_backend() do
    case Application.get_env(:consul_mut_ex, :backend) do
      :ets -> ConsulMutEx.Backends.ETSBackend
    end
  end
end


# In memory lock and Consul-based lock
