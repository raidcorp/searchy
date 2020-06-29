defmodule Searchy.Ecto.Migration do
  defmacro __using__(_opts) do
    quote do
      import Searchy.Ecto.Migration, only: [create_search_for: 3, drop_search_for: 2]
    end
  end

  defmacro create_search_for(table, columns, opts \\ []) do
    search_column = opts[:column] || Enum.join(columns, "_")

    quote location: :keep do
      unquote(table)
      |> Searchy.Ecto.SQL.create_function_sql(unquote(search_column), unquote(columns))
      |> Ecto.Migration.execute()

      unquote(table)
      |> Searchy.Ecto.SQL.create_trigger_sql(unquote(columns))
      |> Ecto.Migration.execute()
    end
  end

  defmacro drop_search_for(table, columns) do
    quote location: :keep do
      unquote(table)
      |> Searchy.Ecto.SQL.drop_trigger_sql(unquote(columns))
      |> Ecto.Migration.execute()

      unquote(table)
      |> Searchy.Ecto.SQL.drop_function_sql(unquote(columns))
      |> Ecto.Migration.execute()
    end
  end
end
