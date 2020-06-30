defmodule Searchy.MixProject do
  use Mix.Project

  def project do
    [
      app: :searchy,
      version: "0.1.1",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ecto, ">= 3.0.0"},
      {:ecto_sql, ">= 3.0.0"},
      {:postgrex, ">= 0.0.0"}
    ]
  end
end
