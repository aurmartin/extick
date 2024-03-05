defmodule ExtickWeb.ProjectLive.Show do
  use ExtickWeb, :live_view

  alias Extick.Projects

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    project = Projects.get_project!(id)

    case project.type do
      "scrum" ->
        {:ok, redirect(socket, to: ~p"/projects/#{id}/current_iteration")}
        # "kanban" -> {:ok, redirect(socket, to: ~p"/projects/#{id}/kanban")}
    end
  end
end
