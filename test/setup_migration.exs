defmodule EctoSearchy.SetupMigration do
  use Ecto.Migration

  import EctoSearchyMigration

  def up do
    create table(:schema_fixture) do
      add(:name, :string)
      add(:age, :integer)
      add(:search_tsvector, :tsvector)

      timestamps()
    end

    create_ecto_searchy_type(:schema_fixture, [:name, :age, :inserted_at])
  end

  def down do
    drop(table("schema_fixture"))

    drop_ecto_searchy_type(:schema_fixture)
  end
end
