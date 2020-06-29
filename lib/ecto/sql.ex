defmodule Searchy.Ecto.SQL do
  @moduledoc false

  import Searchy.Ecto.Helpers

  def create_trigger_sql(table, columns) do
    """
    CREATE TRIGGER #{expand_trigger_name(table, columns)}
    BEFORE INSERT OR UPDATE ON #{table}
    FOR EACH ROW EXECUTE PROCEDURE #{expand_function_name(table, columns)}()
    """
  end

  def drop_trigger_sql(table, columns) do
    "DROP TRIGGER #{expand_trigger_name(table, columns)} ON #{table}"
  end

  def create_function_sql(table, search_column, columns) do
    to_sql = fn search_column ->
      "setweight(to_tsvector('english', coalesce(new.\"#{search_column}\"::TEXT,'')), 'A')"
    end

    definition =
      columns
      |> Enum.map(&to_sql.(&1))
      |> Enum.join(" || ")

    """
    CREATE OR REPLACE FUNCTION #{expand_function_name(table, columns)}()
    RETURNS trigger AS $$
    begin
      new.\"#{search_column}\" := #{definition};
      return new;
    end
    $$ LANGUAGE plpgsql;
    """
  end

  def drop_function_sql(table, columns) do
    "DROP FUNCTION #{expand_function_name(table, columns)}"
  end
end
