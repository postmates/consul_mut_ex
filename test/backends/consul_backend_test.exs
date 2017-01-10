defmodule ConsulMutEx.Backends.ConsulBackendTest do
  use ExUnit.Case
  alias ConsulMutEx.Backends.ConsulBackend

  defp new_key() do
    :rand.uniform(9999999) |> to_string()
  end

  setup_all do
    :ok = ConsulBackend.init()
  end

  describe "acquire_lock/1" do
    test "successfully gets lock" do
      assert {:ok, _lock} = ConsulBackend.acquire_lock(new_key())
    end

    test "fails to acquire lock" do
      key = new_key()
      assert {:ok, _lock} = ConsulBackend.acquire_lock(key, max_retries: 0)
      assert :error == ConsulBackend.acquire_lock(key, max_retries: 0)
    end

    test "max_retries" do
      key = new_key()
      assert {:ok, _lock} = ConsulBackend.acquire_lock(key, max_retries: 0)
      assert :error == ConsulBackend.acquire_lock(key, max_retries: 3)
    end

    test "times out getting lock"
  end

  describe "release_lock/1" do
    test "successfully releases lock" do
      {:ok, lock} = ConsulBackend.acquire_lock(new_key())
      assert :ok == ConsulBackend.release_lock(lock)
    end
  end

  describe "verify_lock/1" do
    test "successfully verifies lock" do
      {:ok, lock} = ConsulBackend.acquire_lock(new_key())
      assert :ok == ConsulBackend.verify_lock(lock)
    end

    test "returns error if someone else owns lock" do
      key = new_key()
      {:ok, lock1} = ConsulBackend.acquire_lock(key)
      assert :ok == ConsulBackend.verify_lock(lock1)
      ConsulBackend.release_lock(lock1)
      assert {:error, nil} = ConsulBackend.verify_lock(lock1)
      {:ok, lock2} = ConsulBackend.acquire_lock(key)
      assert :ok == ConsulBackend.verify_lock(lock2)
      assert {:error, lock2.session} == ConsulBackend.verify_lock(lock1)
    end

    test "returns error if lock is unverified" do
      {:ok, lock} = ConsulBackend.acquire_lock(new_key())
      assert :ok == ConsulBackend.verify_lock(lock)
      ConsulBackend.release_lock(lock)
      assert {:error, nil} == ConsulBackend.verify_lock(lock)
    end
  end
end
