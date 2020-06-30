defmodule Searchy.Ecto.Repo do
  defmacro __using__(_opts) do
    quote do
      import Searchy.Ecto.Repo, only: [search: 3]
    end
  end

  @doc """
  Allows a term to be searched using the `:tsvector` column

  ## Example
      iex> filter = to_tsquery(:search_tsvector, "search term")
      iex> Repo.search(from u in User, filter)      
      iex> Repo.search(from u in User, filter, prefix: "schema")
      
  ## Options
    * `:prefix` - the schema prefix
    
  """
  @spec search(Ecto.Queryable.t(), binary(), keyword()) :: any()
  defmacro search(queryable, term, opts \\ []) do
    quote do
      unquote(queryable)
      |> Map.put(:prefix, unquote(opts[:prefix]))
      |> where([x], ^unquote(term))
    end
  end
end
