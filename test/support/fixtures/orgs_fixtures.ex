defmodule Extick.OrgsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Extick.Orgs` context.
  """

  import Extick.AccountsFixtures

  @doc """
  Generate a org.
  """
  def org_fixture(attrs \\ %{}) do
    {user, attrs} = Map.pop_lazy(Map.new(attrs), :user, fn -> user_fixture() end)

    {:ok, org} =
      Extick.Orgs.create_org(
        user,
        Enum.into(attrs, %{
          name: "some name"
        })
      )

    org
  end
end
