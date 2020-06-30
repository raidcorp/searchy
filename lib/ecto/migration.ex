defmodule Searchy.Ecto.Migration do
  @moduledoc """
  This module provides functions required to create the migrations  
  for the search functionality.

  ### Migrations

  Given a table named `users` where you want to query both `name` and `email`,  
  you would do something similar to the following configuration in your migrations:

  ```
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

  If you are using a lib like [Triplex](https://github.com/ateliware/triplex) for schema-based multi-tenancy, 
  you may also pass a `:prefix` option so the objects are created only within the given schema.

  ### Query

  In your repo:

  ```
  defmodule MyRepo do
    use Ecto.Repo,
      otp_app: :my_app,
      adapter: Ecto.Adapters.Postgres

    use Searchy.Ecto.Repo
  end
  ```

  In your context:

  ```
  import Searchy.Ecto.Query
  
  def search_users_by(search_term) do
    filter = to_tsquery(:search_tsvector, search_term)
    MyRepo.search(from u in User, filter)
  end
  ```

  """

  defmacro __using__(_opts) do
    quote do
      import Searchy.Ecto.Migration,
        only: [
          create_search_for: 2,
          create_search_for: 3,
          drop_search_for: 2,
          drop_search_for: 3
        ]
    end
  end

  @doc """
  Creates the necessary infraestucture to provide full text search functionality.  
  This will create a trigger and a corresponding procedure that will keep the `:tsvector` column updated.
  
  Both the trigger and function will be created with a hash composed of the values of the columns passed.
  So you could for example, define multiple columns that with different search specifications.  

  ## Examples
  
      iex> create_search_for(:users, [:name], column: :name_search)      
      iex> create_search_for(:users, [:name, :email], column: :identifier_search)
      iex> create_search_for(:users, [:inserted_at, :updated_at], column: :update_search)
  
  ## Options
    * `:column` - the column name of `:tsvector` type that will be used by Postgres to search.  
    If nothing is passed, the name of the column will be all the specified columns joined with underscore.
    * `:prefix` - the schema prefix
    
  """
  @spec create_search_for(atom() | binary(), list(atom() | binary()), keyword()) :: any()
  defmacro create_search_for(table, columns, opts \\ [])

  defmacro create_search_for(table, columns, opts) when is_list(opts) do
    search_column = opts[:column] || Enum.join(columns, "_")

    quote location: :keep do
      unquote(table)
      |> Searchy.Ecto.SQL.create_function_sql(
        unquote(search_column),
        unquote(columns),
        unquote(opts[:prefix])
      )
      |> Ecto.Migration.execute()

      unquote(table)
      |> Searchy.Ecto.SQL.create_trigger_sql(unquote(columns), unquote(opts[:prefix]))
      |> Ecto.Migration.execute()
    end
  end

  @doc """
  Drops the created infraestructure that provides the full text search functionality.
  This will drop the corresponding trigger and procedure for the `:tsvector` column.
  
  Notice that, this will only remove the associated trigger and procedure that keeps the search column updated,
  you'll need to remove the `:tsvector` column from the table yourself.
  
  ## Examples
  
      iex> drop_search_for(:users, [:name])      
      iex> drop_search_for(:users, [:name, :email])
      iex> drop_search_for(:users, [:inserted_at, :updated_at])
  
  ## Options
    If nothing is passed, the name of the column will be all the specified columns joined with underscore.
    * `:prefix` - the schema prefix
    
  """
  @spec drop_search_for(atom() | binary(), list(atom() | binary()), keyword()) ::any()
  defmacro drop_search_for(table, columns, opts \\ [])

  defmacro drop_search_for(table, columns, opts) when is_list(opts) do
    quote location: :keep do
      unquote(table)
      |> Searchy.Ecto.SQL.drop_trigger_sql(unquote(columns), unquote(opts[:prefix]))
      |> Ecto.Migration.execute()

      unquote(table)
      |> Searchy.Ecto.SQL.drop_function_sql(unquote(columns), unquote(opts[:prefix]))
      |> Ecto.Migration.execute()
    end
  end
end
