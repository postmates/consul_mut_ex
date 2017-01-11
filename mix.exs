defmodule ConsulMutEx.Mixfile do
  use Mix.Project

  def project do
    [
      app: :consul_mut_ex,
      version: "0.1.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      docs: [
        main: "ConsulMutEx",
        extras: ["README.md"]
      ]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :consul],
     mod: {ConsulMutEx.Supervisor, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ex_doc, "~> 0.14", only: :dev},
      # NOTE: This library's master branch does not have support for sessions.
      # Can be on master branch once this PR is pulled:
      # https://github.com/undeadlabs/consul-ex/pull/7
      {:consul, "~> 1.0.0",
        git: "https://github.com/undeadlabs/consul-ex", branch: "sessions"}
    ]
  end
end
