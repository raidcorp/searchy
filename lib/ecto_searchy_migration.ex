defmodule EctoSearchyMigration do
  defmacro __using__(_opts) do
    quote do
      import EctoSearchyMigration, only: [create_ecto_searchy_type: 2, drop_ecto_searchy_type: 1]
    end
  end

  defmacro create_ecto_searchy_type(table_name, fields) do
    quote location: :keep do
      unquote(table_name)
      |> EctoSearchyMigration.__create_ecto_searchy_function_sql__(:search_tsvector, unquote(fields))
      |> Ecto.Migration.execute()

      unquote(table_name)
      |> EctoSearchyMigration.__create_ecto_searchy_trigger_sql__()
      |> Ecto.Migration.execute()
    end
  end

  defmacro drop_ecto_searchy_type(table_name) do
    quote location: :keep do
      unquote(table_name)
      |> EctoSearchyMigration.__drop_ecto_searchy_trigger_sql__()
      |> Ecto.Migration.execute()

      unquote(table_name)
      |> EctoSearchyMigration.__drop_ecto_searchy_function_sql__()
      |> Ecto.Migration.execute()

      # TODO: Also drop column from table?
    end
  end

  defp expand_function_name(table_name), do: "#{table_name}_ecto_searchy_trigger"

  defp expand_trigger_name(table_name), do: "#{table_name}_ecto_searchy_function"

  @doc false
  def __create_ecto_searchy_trigger_sql__(table_name) do
    """
    CREATE TRIGGER #{expand_trigger_name(table_name)}
    BEFORE INSERT OR UPDATE ON #{table_name}
    FOR EACH ROW EXECUTE PROCEDURE #{expand_function_name(table_name)}()
    """
  end

  @doc false
  def __drop_ecto_searchy_trigger_sql__(table_name) do
    "DROP TRIGGER #{expand_trigger_name(table_name)} ON #{table_name}"
  end

  @doc false
  def __create_ecto_searchy_function_sql__(table_name, field, fields) do
    to_sql = fn field ->
      "setweight(to_tsvector('pg_catalog.english', coalesce(new.\"#{field}\"::TEXT,'')), 'A')"
    end

    definition =
      fields
      |> Enum.map(&to_sql.(&1))
      |> Enum.join(" || ")

    """
    CREATE OR REPLACE FUNCTION #{expand_function_name(table_name)}()
    RETURNS trigger AS $$
    begin
      new.\"#{field}\" := #{definition};
      return new;
    end
    $$ LANGUAGE plpgsql;
    """
  end

  @doc false
  def __drop_ecto_searchy_function_sql__(table_name) do
    "DROP FUNCTION #{expand_function_name(table_name)}"
  end
end
