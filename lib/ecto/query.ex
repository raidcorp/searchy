defmodule Searchy.Ecto.Query do
  import Ecto.Query

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
