defmodule Searchy.Ecto.Repo do

  defmacro __using__(_opts) do
    quote do
      import Searchy.Ecto.Repo, only: [search: 3]
    end
  end

  defmacro search(queryable, term, opts \\ []) do
    quote do
      unquote(queryable)
      |> Map.put(:prefix, unquote(opts[:prefix]))
      |> where([x], ^unquote(term))
    end
  end
end
