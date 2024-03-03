defmodule ExtickWeb.OrgLive.Show do
  use ExtickWeb, :live_view

  alias Extick.Orgs

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    case Orgs.get_org(id) do
      nil ->
        {:noreply, socket |> put_flash(:error, "Org not found") |> redirect(to: "/")}
      org ->
        org = Extick.Repo.preload(org, :projects)
        {:noreply,
         socket
         |> assign(:page_title, page_title(socket.assigns.live_action))
         |> assign(:org, org)}
    end
  end

  defp page_title(:show), do: "Show Org"
  defp page_title(:edit), do: "Edit Org"
end
