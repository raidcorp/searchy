ExUnit.start()

defmodule Searchy.TestRepo do
  use Ecto.Repo, otp_app: :ecto_searchy, adapter: Ecto.Adapters.Postgres

  def log(_cmd), do: nil

  def reload(%{id: id} = item), do: __MODULE__.get(item.__struct__, id)
end

Application.put_env(:ecto_searchy, Searchy.TestRepo,
  url: "ecto://postgres:postgres@localhost/ecto_searchy",
  pool: Ecto.Adapters.SQL.Sandbox
)

defmodule Searchy.SchemaFixture do
  use Ecto.Schema
  use Searchy

  schema "schema_fixture" do
    field(:name, :string)
    field(:age, :integer)
    field(:strict, :boolean)
    field(:search_tsvector, Searchy.Ecto.TSVectorType)

    timestamps()
  end
end

_ = Ecto.Adapters.Postgres.storage_down(Searchy.TestRepo.config())

:ok = Ecto.Adapters.Postgres.storage_up(Searchy.TestRepo.config())

{:ok, _pid} = Searchy.TestRepo.start_link()

Code.require_file("setup_migration.exs", __DIR__)

:ok = Ecto.Migrator.up(Searchy.TestRepo, 0, Searchy.SetupMigration, log: false)

Ecto.Adapters.SQL.Sandbox.mode(Searchy.TestRepo, {:shared, self()})
