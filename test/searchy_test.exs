defmodule SearchyTest do
  use ExUnit.Case
  import Ecto.Query

  alias Searchy.{TestRepo, SchemaFixture}

  doctest Searchy

  setup do
    TestRepo.delete_all(SchemaFixture)

    Enum.each(fixtures(), &TestRepo.insert!/1)
  end

  test "returns correct tsvector name data" do
    q = "jane:*"

    assert [%{name: "Jane Doe"}] = TestRepo.all(
      from s in SchemaFixture,
        where: fragment("? @@ to_tsquery(?)", s.search_tsvector, ^q)
    )
  end

  test "returns correct tsvector age data" do
    q = "33:*"

    assert [%{name: "John Doe"}] = TestRepo.all(
      from s in SchemaFixture,
        where: fragment("? @@ to_tsquery(?)", s.search_tsvector, ^q)
    )
  end

  test "returns correct tsvector inserted_at data" do
    q = "2020-06-04:*"

    assert [%{name: "John doe ||"}] = TestRepo.all(
      from s in SchemaFixture,
        where: fragment("? @@ to_tsquery(?)", s.search_tsvector, ^q)
    )
  end

  defp fixtures do
    [
      %SchemaFixture{name: "John Doe", age: 33},
      %SchemaFixture{name: "Jane Doe", age: 30},
      %SchemaFixture{name: "John doe ||", age: 18, inserted_at: ~N[2020-06-04 00:00:00]}
    ]
  end
end
