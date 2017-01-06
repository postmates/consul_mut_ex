defmodule ConsulMutEx.Backends.ETSBackendTest do
  use ExUnit.Case
  alias ConsulMutEx.Backends.ETSBackend

  defp new_key() do
    :rand.uniform(9999999) |> to_string()
  end

  setup_all do
    ETSBackend.init()

    :ok
  end

  describe "acquire_lock/2" do
    test "successfully gets lock" do
      assert {:ok, lock} = ETSBackend.acquire_lock(new_key())
    end

    test "fails to acquire lock" do
      key = new_key()

      assert {:ok, lock} = ETSBackend.acquire_lock(key, timeout: 0)
      assert :error == ETSBackend.acquire_lock(key, timeout: 0)
    end

    test "times out getting lock"
  end
end
