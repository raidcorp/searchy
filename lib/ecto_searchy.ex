defmodule Searchy do
  require Ecto.Schema

  alias Searchy.Ecto.TSVectorType

  defmacro __using__(_opts) do
    quote do
      import Searchy, only: [tsvector_field: 0]
    end
  end

  defmacro tsvector_field() do
    quote do
      Ecto.Schema.field(:tsvector_search, TSVectorType)
    end
  end
end
