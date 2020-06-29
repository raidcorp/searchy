defmodule Searchy.Ecto.RepoTest do
  use ExUnit.Case
  import Ecto.Query
  import Searchy.Ecto.Query
  import Searchy.Ecto.Repo

  alias Searchy.User

  doctest Searchy

  describe "search/3" do
    test "uses prefix when defined" do
      filter = to_tsquery(:search_tsvector, "search term")
      query = from(u in User)
      assert %Ecto.Query{prefix: "foo"} = search(query, filter, prefix: "foo")
    end

    test "prefix defaults to nil when not defined" do
      filter = to_tsquery(:search_tsvector, "search term")
      query = from(u in User)
      assert %Ecto.Query{prefix: nil} = search(query, filter)
    end
  end
end
