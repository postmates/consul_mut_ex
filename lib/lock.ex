defmodule ConsulMutEx.Lock do
  defstruct [
    key: nil
  ]

  @type t :: %{
    key: String.t | nil
  }
end
