defmodule Extick.ProjectsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Extick.Projects` context.
  """

  import Extick.OrgsFixtures

  def unique_project_key do
    suffix =
      System.unique_integer([:positive])
      |> Integer.digits()
      |> Enum.map(&(?A + &1))

    "KEY#{suffix}"
  end

  @doc """
  Generate a project.
  """
  def project_fixture(attrs \\ %{}) do
    attrs = Map.new(attrs)

    {:ok, project} =
      attrs
      |> Map.put_new_lazy(:org_id, fn -> org_fixture().id end)
      |> Enum.into(%{
        description: "some description",
        key: unique_project_key(),
        name: "some name",
        type: "scrum"
      })
      |> Extick.Projects.create_project()

    project
  end
end
