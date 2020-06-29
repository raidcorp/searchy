defmodule Searchy.Ecto.Helpers do
  @moduledoc false

  def expand_function_name(table_name, fields) do
    digest = digest_fields(fields)
    "#{table_name}_searchy_function_#{digest}"
  end

  def expand_trigger_name(table_name, fields) do
    digest = digest_fields(fields)
    "#{table_name}_searchy_trigger_#{digest}"
  end

  defp digest_fields(fields) do
    :md4
    |> :crypto.hash(Enum.join(fields))
    |> :binary.decode_unsigned()
  end
end
