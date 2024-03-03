defmodule Extick.OrgsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Extick.Orgs` context.
  """

  @doc """
  Generate a org.
  """
  def org_fixture(attrs \\ %{}) do
    {:ok, org} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Extick.Orgs.create_org()

    org
  end
end
