defmodule EctoSearchy.Ecto.TSVectorType do
  use Ecto.Type

  def type, do: :tsvector

  def cast(tsvector), do: {:ok, tsvector}

  def load(tsvector), do: {:ok, tsvector}

  def dump(tsvector), do: {:ok, tsvector}

  def embed_as(_), do: :self

  def equal?(term1, term2), do: term1 == term2
end
