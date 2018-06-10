defmodule HoloshareServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :holoshare_server,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {HoloshareServer.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poolboy, "~> 1.5.1"},
      {:poison, "~> 3.1"},
      {:uuid, "~> 1.1.8"},
    ]
  end
end
