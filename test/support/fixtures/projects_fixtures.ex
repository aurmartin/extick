defmodule Extick.ProjectsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Extick.Projects` context.
  """

  @doc """
  Generate a project.
  """
  def project_fixture(attrs \\ %{}) do
    {:ok, project} =
      attrs
      |> Enum.into(%{
        description: "some description",
        key: "some key",
        name: "some name"
      })
      |> Extick.Projects.create_project()

    project
  end
end
