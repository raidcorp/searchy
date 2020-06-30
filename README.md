# Searchy

Searchy provides functionality that helps you implement full text search with Postgres

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `searchy` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:searchy, "~> 0.1.0"}
  ]
end
```

Alternatively, you can link package directly from this repository:

```elixir
def deps do
  [
    {:searchy, git: "https://github.com/raidcorp/searchy", tag: "v0.1.0"}
  ]
end
```

## Usage

### Migrations

Given a table named `users` where you want to query both `name` and `email`, you would do something similar to the following configuration in your migrations:

```elixir
use Searchy.Ecto.Migration

def up do
  alter table(:users) do
    add :search_tsvector, :tsvector
  end

  create_search_for(:users, [:name, :email], column: :search_tsvector)
  create index(:users, [:search_tsvector], using: :gin)
end

def down do
  drop index(:users, [:search_tsvector])
  drop_search_for(:users, [:name, :email])

  alter table(:users) do
    remove :search_tsvector
  end
end
```

> If you are using a lib like [Triplex](https://github.com/ateliware/triplex) for schema-based multi-tenancy, you may also pass a `:prefix` option so the objects are created only within the given schema.

### Query

In your repo:

```elixir
defmodule MyRepo do
  use Ecto.Repo,
    otp_app: :my_app,
    adapter: Ecto.Adapters.Postgres

  use Searchy.Ecto.Repo
end
```

In your context:

```elixir
def search_users_by(search_term) do
  filter = to_tsquery(:search_tsvector, search_term)
  MyRepo.search(from u in User, filter)
end
```