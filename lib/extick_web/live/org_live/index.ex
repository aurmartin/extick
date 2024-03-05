defmodule ExtickWeb.OrgLive.Index do
  use ExtickWeb, :live_view

  alias Extick.Orgs
  alias Extick.Orgs.Org

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :orgs, Orgs.list_joined_orgs(socket.assigns.current_user.id))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Organization")
    |> assign(:org, %Org{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Your Organizations")
    |> assign(:org, nil)
  end

  @impl true
  def handle_info({ExtickWeb.OrgLive.FormComponent, {:saved, org}}, socket) do
    {:noreply, stream_insert(socket, :orgs, org)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    org = Orgs.get_org!(id)
    {:ok, _} = Orgs.delete_org(org)

    {:noreply, stream_delete(socket, :orgs, org)}
  end
end
