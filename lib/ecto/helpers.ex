defmodule Searchy.Ecto.Helpers do
  @moduledoc false
  
  def expand_function_name(table_name, fields) do
    digest = digest_fields(table_name, fields)
    
    "searchy_function_#{digest}"
  end

  def expand_trigger_name(table_name, fields) do
    digest = digest_fields(table_name, fields)
    
    "searchy_trigger_#{digest}"
  end

  def escape_prefix_name(term, nil), do: escape_prefix_name(term, :public)

  def escape_prefix_name(term, prefix), do: ~s("#{prefix}"."#{term}")

  def digest_fields(table_name, fields) do
    :md4
    |> :crypto.hash("#{table_name}#{Enum.join(fields)}")
    |> Base.encode64(padding: false)
  end
end
