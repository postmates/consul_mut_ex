defmodule ConsulMutEx.Lock do
  defstruct [
    key: nil,
    owner: nil
  ]

  @type t :: %{
    key: String.t | nil,
    owner: pid() | nil
  }
end
