defmodule ConsulMutEx.Lock do
  defstruct [
    key: nil,
    owner: nil,
    session: nil
  ]

  @type t :: %{
    key: String.t | nil,
    owner: pid() | nil,
    session: String.t | nil
  }
end
