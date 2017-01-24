defmodule ConsulMutEx do
  @moduledoc """

  Examples:

      iex> Application.put_env(:consul_mut_ex, :backend, :consul)
      iex> ConsulMutEx.init()
      iex> ConsulMutEx.lock("test_key", max_retries: 0) do
      ...>   :acquired
      ...> else
      ...>   :failed_to_acquire
      ...> end
      :acquired
      iex> {:ok, lock} = ConsulMutEx.acquire_lock("test_key", max_retries: 0)
      iex> ConsulMutEx.lock("test_key", max_retries: 0) do
      ...>   :acquired
      ...> else
      ...>   :failed_to_acquire
      ...> end
      :failed_to_acquire
      iex> ConsulMutEx.verify_lock(lock)
      :ok
      iex> ConsulMutEx.release_lock(lock)
      :ok
      iex> ConsulMutEx.verify_lock(lock)
      {:error, nil}
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
  Verify a lock
  """
  @spec verify_lock(Lock.t) :: :ok | {:error, any()}
  def verify_lock(lock) do
    get_backend().verify_lock(lock)
  end

  @doc """
  Lock and run a code block
  """
  @spec lock(String.t, keyword(), keyword()) :: any()
  defmacro lock(key, opts \\ [], clauses) do
    do_lock(key, opts, clauses)
  end

  defp do_lock(key, opts, do: do_clause) do
    do_lock(key, opts, do: do_clause, else: nil)
  end

  defp do_lock(key, opts, do: do_clause, else: else_clause) do
    quote do
      case ConsulMutEx.acquire_lock(unquote(key), unquote(opts)) do
        {:ok, lock} ->
          try do
            # Acquired the lock
            unquote(do_clause)
          after
            # Release the lock
            ConsulMutEx.release_lock(lock)
          end
        :error ->
          unquote(else_clause)
      end
    end
  end

  @doc """
  Delete a key
  """
  @spec delete_key(String.t, keyword()) :: :ok
  def delete_key(key, opts \\ []) do
    get_backend().delete_key(key, opts)
  end


  @doc """
  Initialize the configured backend.

  Note: This will be called when this application is started.
        If you change the backend after application is loaded,
        you may need to call this manually.
  """
  @spec init() :: :ok
  def init() do
    get_backend().init()
  end

  defp get_backend() do
    case Application.get_env(:consul_mut_ex, :backend) do
      :ets -> ConsulMutEx.Backends.ETSBackend
      :consul -> ConsulMutEx.Backends.ConsulBackend
    end
  end
end
