defmodule Searchy.Ecto.Migration do
  defmacro __using__(_opts) do
    quote do
      import Searchy.Ecto.Migration, only: [create_search_for: 2, drop_search_for: 1]
    end
  end

  defmacro create_search_for(table, columns, opts \\ []) do

    search_column = opts[:column] || Enum.join(columns, "_")

    quote location: :keep do
      unquote(table)
      |> Searchy.Ecto.Migration.__create_function_sql__(unquote(search_column), unquote(columns))
      |> Ecto.Migration.execute()

      unquote(table)
      |> Searchy.Ecto.Migration.__create_trigger_sql__(unquote(columns))
      |> Ecto.Migration.execute()
    end
  end

  defmacro drop_search_for(table, columns) do
    quote location: :keep do
      unquote(table)
      |> Searchy.Ecto.Migration.__drop_searchy_trigger_sql__(unquote(columns))
      |> Ecto.Migration.execute()

      unquote(table)
      |> Searchy.Ecto.Migration.__drop_searchy_function_sql__(unquote(columns))
      |> Ecto.Migration.execute()
    end
  end

  @doc false
  def __create_trigger_sql__(table, columns) do
    """
    CREATE TRIGGER #{Searchy.Ecto.Helpers.expand_trigger_name(table, columns)}
    BEFORE INSERT OR UPDATE ON #{table}
    FOR EACH ROW EXECUTE PROCEDURE #{Searchy.Ecto.Helpers.expand_function_name(table, columns)}()
    """
  end

  @doc false
  def __drop_searchy_trigger_sql__(table, columns) do
    "DROP TRIGGER #{Searchy.Ecto.Helpers.expand_trigger_name(table, columns)} ON #{table}"
  end

  @doc false
  def __create_function_sql__(table, search_column, columns) do
    to_sql = fn search_column ->
      "setweight(to_tsvector('english', coalesce(new.\"#{search_column}\"::TEXT,'')), 'A')"
    end

    definition =
      columns
      |> Enum.map(&to_sql.(&1))
      |> Enum.join(" || ")

    """
    CREATE OR REPLACE FUNCTION #{Searchy.Ecto.Helpers.expand_function_name(table, columns)}()
    RETURNS trigger AS $$
    begin
      new.\"#{search_column}\" := #{definition};
      return new;
    end
    $$ LANGUAGE plpgsql;
    """
  end

  @doc false
  def __drop_searchy_function_sql__(table, columns) do
    "DROP FUNCTION #{Searchy.Ecto.Helpers.expand_function_name(table, columns)}"
  end
end
