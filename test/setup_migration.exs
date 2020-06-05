defmodule Searchy.SetupMigration do
  use Ecto.Migration

  import Searchy.Ecto.Migration

  def up do
    create table(:schema_fixture) do
      add(:name, :string)
      add(:age, :integer)
      add(:strict, :boolean)
      add(:search_tsvector, :tsvector)

      timestamps()
    end

    create_searchy_type(:schema_fixture, [:name, :age, :strict, :inserted_at])
  end

  def down do
    drop(table("schema_fixture"))

    drop_searchy_type(:schema_fixture)
  end
end
