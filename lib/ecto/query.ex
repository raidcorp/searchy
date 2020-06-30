defmodule Searchy.Ecto.Query do
  @moduledoc """
  Provides search functionality to work with `tsvector` columns.
  For more information you can lookup the Postgres documentation on:
  https://www.postgresql.org/docs/current/textsearch-controls.html
  """

  import Ecto.Query

  @doc """
  Transforms the `search_term` in a Postgres `tsquery` data type fragment.
  """
  @spec to_tsquery(atom() | binary(), binary()) :: %Ecto.Query.DynamicExpr{}
  def to_tsquery(search_field, search_term) do
    dynamic(
      [x],
      fragment(
        "? @@ to_tsquery(?)",
        field(x, ^search_field),
        ^search_term
      )
    )
  end

  @doc false
  def plainto_tsquery(search_field, search_term) do
    dynamic(
      [x],
      fragment(
        "? @@ plainto_tsquery(?)",
        field(x, ^search_field),
        ^search_term
      )
    )
  end

  @doc false
  def ts_rank(search_field, search_term) do
    dynamic(
      [x],
      fragment(
        "? @@ ts_rank(?)",
        field(x, ^search_field),
        ^search_term
      )
    )
  end

  @doc false
  def ts_rank_cd(search_field, search_term) do
    dynamic(
      [x],
      fragment(
        "? @@ ts_rank_cd(?)",
        field(x, ^search_field),
        ^search_term
      )
    )
  end

  @doc false
  def ts_headline(search_field, search_term) do
    dynamic(
      [x],
      fragment(
        "? @@ ts_headline(?)",
        field(x, ^search_field),
        ^search_term
      )
    )
  end
end
