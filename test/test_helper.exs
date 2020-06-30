ExUnit.start()

defmodule Searchy.TestRepo do
  use Ecto.Repo, otp_app: :searchy, adapter: Ecto.Adapters.Postgres
  use Searchy.Ecto.Repo

  def log(_cmd), do: nil

  def reload(%{id: id} = item), do: __MODULE__.get(item.__struct__, id)
end

Application.put_env(:searchy, Searchy.TestRepo,
  url: "ecto://postgres:postgres@localhost/searchy",
  pool: Ecto.Adapters.SQL.Sandbox,
  log: false
)

defmodule Searchy.User do
  use Ecto.Schema

  schema "users" do
    field(:name, :string)
    field(:age, :integer)
    field(:active?, :boolean)
    field(:search_tsvector, Searchy.Ecto.Types.TSVector)

    timestamps()
  end
end

_ = Ecto.Adapters.Postgres.storage_down(Searchy.TestRepo.config())

:ok = Ecto.Adapters.Postgres.storage_up(Searchy.TestRepo.config())

{:ok, _pid} = Searchy.TestRepo.start_link()

Code.require_file("setup_migration.exs", __DIR__)

:ok = Ecto.Migrator.up(Searchy.TestRepo, 0, Searchy.SetupMigration, log: false)

Ecto.Adapters.SQL.Sandbox.mode(Searchy.TestRepo, {:shared, self()})
