defmodule ConsulMutEx.Backends.ConsulBackend do
  @moduledoc """
  Use Hashicorp's Consul KV store to acquire and release locks.

  [Consul documentation](https://www.consul.io/docs/agent/http/kv.html)
  """

  alias Consul.Session

  @timeout 1000

  @doc """
  Initialize this backend.
  """
  @spec init() :: :ok
  def init() do
    :ok
  end

  @doc """
  Acquire a lock.

  ## Arguments:

    * `key`: A key to identify the lock
    * `opts`: Options
      * `acquire`: The Consul session ID of the lock
      * `max_retries`: Maximum number of retries, defaults to 0.
      * `cooldown`: Milliseconds to sleep between retries, defaults to 1000.
  """
  @spec acquire_lock(String.t, keyword()) :: {:ok, Lock.t} | :error
  def acquire_lock(key, opts \\ []) do
    do_acquire_lock(key, opts, 0)
  end

  defp do_acquire_lock(key, opts, retries) do
    session = create_session()

    if Consul.Kv.put(key, session, acquire: session) do
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
  @spec release_lock(Lock.t) :: :ok
  def release_lock(lock) do
    if Consul.Kv.put(lock.key, lock.session, release: lock.session) do
      :ok
    else
      :error
    end
  end

  @doc """
  Verify a lock.
  """
  @spec verify_lock(Lock.t) :: :ok | {:error, any()}
  def verify_lock(lock) do
    {:ok, resp} = Consul.Kv.fetch(lock.key)
    session_id = resp.body
      |> List.first
      |> Map.get("Session")

    cond do
      session_id == lock.session -> :ok
      is_nil(session_id) -> {:error, nil}
      true -> {:error, session_id}
    end
  end


  @doc """
  Delete a key or all keys sharing a prefix.

  ## Arguments:

    * `key`: A key
    * `opts`: Options
      * `recurse`: if present, delete all keys which have the
                   specified prefix
      * `cas`: Used to turn delete into a Check-And-Set operation
               If the index is non-zero, the key is only deleted
               if the index matches the ModifyIndex of that key
  """
  @spec delete_key(String.t, keyword()) :: :ok
  def delete_key(key, opts \\ []) do
    if Consul.Kv.delete(key, opts) do
      :ok
    else
      :error
    end
  end

  defp new_lock(key, session) do
    %ConsulMutEx.Lock{
      key: key,
      owner: self(),
      session: session
    }
  end

  def create_session() do
    {:ok,
      %HTTPoison.Response{body: %{"ID" => session_id}}
    } = Session.create(%{})

    session_id
  end
end
