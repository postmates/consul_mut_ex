defmodule ConsulMutEx.Mixfile do
  use Mix.Project

  def project do
    [
      app: :consul_mut_ex,
      version: "1.0.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description: description(),
      deps: deps(),
      package: package(),
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

  defp description do
    "An Elixir locking library that supports Consul and ets as a backend."
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
      # NOTE: This library's master branch does not have support for sessions
      # and deleting kv so we're using a fork with the features we need.
      {:consul, "~> 1.0.0", github: "jennhuang/consul-ex", override: true}
    ]
  end

  defp package do
    [
      name: :consul_mut_ex,
      maintainers: ["Andrew Mager", "Geoff Hayes", "Jennifer Huang"],
      licenses: ["BSD 3-Clause"],
      links: %{"GitHub" => "https://github.com/postmates/consul_mut_ex"},
    ]
 end
end
