defmodule Searchy.Ecto.SQL do
  @moduledoc false

  import Searchy.Ecto.Helpers

  def create_trigger_sql(table, columns, prefix) do
    table_name = escape_prefix_name(table, prefix)
    trigger_name = expand_trigger_name(table, columns)
    
    function_name =
      table
      |> expand_function_name(columns)
      |> escape_prefix_name(prefix)
      
    """
    CREATE TRIGGER "#{trigger_name}"
    BEFORE INSERT OR UPDATE ON #{table_name}
    FOR EACH ROW EXECUTE PROCEDURE #{function_name}()
    """
  end

  def drop_trigger_sql(table, columns, prefix) do
    table_name = escape_prefix_name(table, prefix)
    trigger_name = expand_trigger_name(table, columns)
    
    ~s(DROP TRIGGER IF EXISTS "#{trigger_name}" ON #{table_name})
  end

  def create_function_sql(table, search_column, columns, prefix) do
    to_sql = fn search_column ->
      "setweight(to_tsvector('english', coalesce(new.\"#{search_column}\"::TEXT,'')), 'A')"
    end

    definition =
      columns
      |> Enum.map(&to_sql.(&1))
      |> Enum.join(" || ")
      
    function_name =
      table
      |> expand_function_name(columns)
      |> escape_prefix_name(prefix)
      
    """
    CREATE OR REPLACE FUNCTION #{function_name}()
    RETURNS trigger AS $$
    begin
      new.\"#{search_column}\" := #{definition};
      return new;
    end
    $$ LANGUAGE plpgsql;
    """
  end

  def drop_function_sql(table, columns, prefix) do
    function_name =
      table
      |> expand_function_name(columns)
      |> escape_prefix_name(prefix)

    "DROP FUNCTION #{function_name}"
  end
end
