defmodule Searchy.Ecto.Migration do
  defmacro __using__(_opts) do
    quote do
      import Searchy.Ecto.Migration, only: [create_search_for: 2, drop_search_for: 1]
    end
  end

  defmacro create_search_for(table_name, fields, field) do
    quote location: :keep do
      unquote(table_name)
      |> Searchy.Ecto.Migration.__create_function_sql__(unquote(field), unquote(fields))
      |> Ecto.Migration.execute()

      unquote(table_name)
      |> Searchy.Ecto.Migration.__create_trigger_sql__(unquote(fields))
      |> Ecto.Migration.execute()
    end
  end

  defmacro drop_search_for(table_name, fields) do
    quote location: :keep do
      unquote(table_name)
      |> Searchy.Ecto.Migration.__drop_searchy_trigger_sql__(unquote(fields))
      |> Ecto.Migration.execute()

      unquote(table_name)
      |> Searchy.Ecto.Migration.__drop_searchy_function_sql__(unquote(fields))
      |> Ecto.Migration.execute()
    end
  end

  @doc false
  def __create_trigger_sql__(table_name, fields) do
    """
    CREATE TRIGGER #{Searchy.Ecto.Helpers.expand_trigger_name(table_name, fields)}
    BEFORE INSERT OR UPDATE ON #{table_name}
    FOR EACH ROW EXECUTE PROCEDURE #{Searchy.Ecto.Helpers.expand_function_name(table_name, fields)}()
    """
  end

  @doc false
  def __drop_searchy_trigger_sql__(table_name, fields) do
    "DROP TRIGGER #{Searchy.Ecto.Helpers.expand_trigger_name(table_name, fields)} ON #{table_name}"
  end

  @doc false
  def __create_function_sql__(table_name, field, fields) do
    to_sql = fn field ->
      "setweight(to_tsvector('english', coalesce(new.\"#{field}\"::TEXT,'')), 'A')"
    end

    definition =
      fields
      |> Enum.map(&to_sql.(&1))
      |> Enum.join(" || ")

    """
    CREATE OR REPLACE FUNCTION #{Searchy.Ecto.Helpers.expand_function_name(table_name, fields)}()
    RETURNS trigger AS $$
    begin
      new.\"#{field}\" := #{definition};
      return new;
    end
    $$ LANGUAGE plpgsql;
    """
  end

  @doc false
  def __drop_searchy_function_sql__(table_name, fields) do
    "DROP FUNCTION #{Searchy.Ecto.Helpers.expand_function_name(table_name, fields)}"
  end
end
