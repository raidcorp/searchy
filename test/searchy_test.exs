defmodule SearchyTest do
  use ExUnit.Case
  import Ecto.Query
  import Searchy.Ecto.Query

  alias Searchy.{TestRepo, User}

  doctest Searchy

  setup do
    TestRepo.delete_all(User)
    Enum.each(fixtures(), &TestRepo.insert!/1)
  end

  describe "returns correct result for" do
    test "string search" do
      search_term = "foo:*"

      filter = to_tsquery(:search_tsvector, search_term)

      assert [%{name: "Foo"}] = TestRepo.all(from(u in User, where: ^filter))
    end

    test "integer search" do
      search_term = "42:*"

      filter = to_tsquery(:search_tsvector, search_term)

      assert [%{name: "Fred"}] = TestRepo.all(from(u in User, where: ^filter))
    end

    test "date search" do
      search_term = "1970-01-01:*"

      filter = to_tsquery(:search_tsvector, search_term)

      assert [%{name: "Thud"}] = TestRepo.all(from(u in User, where: ^filter))
    end

    test "boolean search" do
      search_term = "true:*"

      filter = to_tsquery(:search_tsvector, search_term)

      assert [%{name: "Xyzzy"}] = TestRepo.all(from(u in User, where: ^filter))
    end

    defp fixtures do
      [
        %User{name: "Foo", age: 0},
        %User{name: "Bar", age: 1},
        %User{name: "Baz", age: 2},
        %User{name: "Qux", age: 3},
        %User{name: "Quux", age: 4},
        %User{name: "Quuz", age: 5},
        %User{name: "Corge", age: 6},
        %User{name: "Grault", age: 7},
        %User{name: "Garply", age: 8},
        %User{name: "Waldo", age: 9},
        %User{name: "Fred", age: 42},
        %User{name: "Plugh", age: 0},
        %User{name: "Xyzzy", age: 0, active?: true},
        %User{name: "Thud", age: 0, inserted_at: ~N[1970-01-01 00:00:00]}
      ]
    end
  end
end
