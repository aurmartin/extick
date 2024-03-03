defmodule ExtickWeb.ProjectLive.New do
  use ExtickWeb, :live_view

  alias Extick.Projects

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, step: :select_type)}
  end

  @impl true
  def handle_event("select_type", %{"type" => type}, socket) do
    %{current_org_id: current_org_id} = socket.assigns

    {:noreply,
     socket
     |> assign(
       step: :enter_details,
       project: %Projects.Project{type: type, org_id: current_org_id}
     )}
  end
end
