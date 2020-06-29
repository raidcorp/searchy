defmodule Searchy.SetupMigration do
  use Ecto.Migration

  import Searchy.Ecto.Migration

  def up do
    create table(:users) do
      add(:name, :string)
      add(:age, :integer)
      add(:active?, :boolean)
      add(:search_tsvector, :tsvector)

      timestamps()
    end

    create_search_for(:users, [:name, :age, :active?, :inserted_at], :search_tsvector)
  end

  def down do
    drop(table("users"))

    drop_search_for(:users, [:name, :age, :active?, :inserted_at])
  end
end
