defmodule ConsulMutEx.Supervisor do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    # Initialize our storage
    ConsulMutEx.init()

    children = []
    opts = [strategy: :one_for_one, name: __MODULE__]

    Supervisor.start_link(children, opts)
  end
end
