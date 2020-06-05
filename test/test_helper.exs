ExUnit.start()

defmodule EctoSearchy.TestRepo do
  use Ecto.Repo, otp_app: :ecto_searchy, adapter: Ecto.Adapters.Postgres

  def log(_cmd), do: nil

  def reload(%{id: id} = item), do: __MODULE__.get(item.__struct__, id)
end

Application.put_env(:ecto_searchy, EctoSearchy.TestRepo,
  url: "ecto://postgres:postgres@localhost/ecto_searchy",
  pool: Ecto.Adapters.SQL.Sandbox
)

defmodule EctoSearchy.SchemaFixture do
  use Ecto.Schema
  use EctoSearchy

  schema "schema_fixture" do
    field(:name, :string)
    field(:age, :integer)
    field(:strict, :boolean)
    field(:search_tsvector, EctoSearchy.Ecto.TSVectorType)

    timestamps()
  end
end

_ = Ecto.Adapters.Postgres.storage_down(EctoSearchy.TestRepo.config())

:ok = Ecto.Adapters.Postgres.storage_up(EctoSearchy.TestRepo.config())

{:ok, _pid} = EctoSearchy.TestRepo.start_link()

Code.require_file("setup_migration.exs", __DIR__)

:ok = Ecto.Migrator.up(EctoSearchy.TestRepo, 0, EctoSearchy.SetupMigration, log: false)

Ecto.Adapters.SQL.Sandbox.mode(EctoSearchy.TestRepo, {:shared, self()})
