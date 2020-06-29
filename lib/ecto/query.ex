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
end
