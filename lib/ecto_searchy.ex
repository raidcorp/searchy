defmodule EctoSearchy do
  require Ecto.Schema

  alias EctoSearchy.Ecto.TSVectorType

  defmacro __using__(_opts) do
    quote do
      import EctoSearchy, only: [tsvector_field: 0]
    end
  end

  defmacro tsvector_field() do
    quote do
      Ecto.Schema.field(:tsvector_search, TSVectorType)
    end
  end
end
