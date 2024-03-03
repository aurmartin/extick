defmodule Extick.OrgsTest do
  use Extick.DataCase

  alias Extick.Orgs

  describe "orgs" do
    alias Extick.Orgs.Org

    import Extick.OrgsFixtures

    @invalid_attrs %{name: nil}

    test "list_orgs/0 returns all orgs" do
      org = org_fixture()
      assert Orgs.list_orgs() == [org]
    end

    test "get_org!/1 returns the org with given id" do
      org = org_fixture()
      assert Orgs.get_org!(org.id) == org
    end

    test "create_org/1 with valid data creates a org" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Org{} = org} = Orgs.create_org(valid_attrs)
      assert org.name == "some name"
    end

    test "create_org/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Orgs.create_org(@invalid_attrs)
    end

    test "update_org/2 with valid data updates the org" do
      org = org_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Org{} = org} = Orgs.update_org(org, update_attrs)
      assert org.name == "some updated name"
    end

    test "update_org/2 with invalid data returns error changeset" do
      org = org_fixture()
      assert {:error, %Ecto.Changeset{}} = Orgs.update_org(org, @invalid_attrs)
      assert org == Orgs.get_org!(org.id)
    end

    test "delete_org/1 deletes the org" do
      org = org_fixture()
      assert {:ok, %Org{}} = Orgs.delete_org(org)
      assert_raise Ecto.NoResultsError, fn -> Orgs.get_org!(org.id) end
    end

    test "change_org/1 returns a org changeset" do
      org = org_fixture()
      assert %Ecto.Changeset{} = Orgs.change_org(org)
    end
  end
end
