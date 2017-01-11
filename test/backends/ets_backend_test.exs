defmodule ConsulMutEx.Backends.ETSBackendTest do
  use ExUnit.Case
  alias ConsulMutEx.Backends.ETSBackend

  defp new_key() do
    :rand.uniform(9999999) |> to_string()
  end

  setup_all do
    :ok = ETSBackend.init()
  end

  describe "acquire_lock/2" do
    test "successfully gets lock" do
      assert {:ok, _lock} = ETSBackend.acquire_lock(new_key())
    end

    test "fails to acquire lock" do
      key = new_key()

      assert {:ok, _lock} = ETSBackend.acquire_lock(key, max_retries: 0)
      assert :error == ETSBackend.acquire_lock(key, max_retries: 0)
    end

    test "max_retries" do
      key = new_key()
      assert {:ok, _lock} = ETSBackend.acquire_lock(key, max_retries: 0)
      assert :error == ETSBackend.acquire_lock(key, max_retries: 2)
    end

    test "times out getting lock"
  end

  describe "release_lock/1" do
    test "successfully releases lock" do
      key = new_key()
      {:ok, lock} = ETSBackend.acquire_lock(key)
      assert :ok == ETSBackend.release_lock(lock)
      assert {:ok, _lock2} = ETSBackend.acquire_lock(key)
    end
  end

  describe "verify_lock/1" do
    test "successfully verifies lock" do
      {:ok, lock} = ETSBackend.acquire_lock(new_key())
      assert :ok == ETSBackend.verify_lock(lock)
    end

    test "returns error if someone else owns lock" do
      key = new_key()
      {:ok, lock1} = ETSBackend.acquire_lock(key)
      assert :ok == ETSBackend.verify_lock(lock1)
      ETSBackend.release_lock(lock1)
      {:ok, lock2} = ETSBackend.acquire_lock(key)
      assert :ok == ETSBackend.verify_lock(lock2)
      assert {:error, lock2.session} == ETSBackend.verify_lock(lock1)
    end

    test "returns error if lock is unverified" do
      {:ok, lock} = ETSBackend.acquire_lock(new_key())
      assert :ok == ETSBackend.verify_lock(lock)
      ETSBackend.release_lock(lock)
      assert {:error, nil} == ETSBackend.verify_lock(lock)
    end
  end
end
