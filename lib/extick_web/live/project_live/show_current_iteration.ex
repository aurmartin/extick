defmodule ExtickWeb.ProjectLive.ShowCurrentIteration do
  use ExtickWeb, {:live_view, layout: :project}

  alias Extick.Tickets
  alias Extick.Projects

  import ExtickWeb.ProjectLive.Components

  @impl true
  def mount(params, _session, socket) do
    %{"id" => id} = params

    project = Projects.get_project!(id)
    tickets = Tickets.list_tickets_by_project_and_statuses(id, ["open", "in_progress", "done"])

    {:ok, assign(socket, project: project, tickets: tickets, project_page: "backlog")}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, _params) do
    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
  end

  defp apply_action(socket, :edit_ticket, %{"ticket_id" => ticket_id}) do
    ticket = Tickets.get_ticket!(ticket_id)
    assign(socket, page_title: "Edit Ticket", ticket: ticket)
  end

  defp apply_action(socket, :new_ticket, _params) do
    %{project: project, current_user: current_user} = socket.assigns

    ticket = %Tickets.Ticket{
      project_id: project.id,
      priority: 3,
      reporter_id: current_user.id
    }

    assign(socket, page_title: "New Ticket", ticket: ticket)
  end

  @impl true
  def handle_event("move_ticket", params, socket) do
    %{
      "id" => id,
      "newIndex" => _new_index,
      "newStatus" => new_status,
      "oldIndex" => _old_index,
      "oldStatus" => _old_status
    } = params

    ticket = Tickets.get_ticket!(id)
    {:ok, _ticket} = Tickets.update_ticket(ticket, %{status: new_status})

    tickets = Tickets.list_tickets_by_project_and_statuses(params.project_id, ["open", "in_progress", "done"])

    {:noreply, assign(socket, tickets: tickets)}
  end

  @impl true
  def handle_info({ExtickWeb.TicketLive.FormComponent, {:saved, _ticket}}, socket) do
    tickets = Tickets.list_tickets_by_project_and_statuses(socket.assigns.project.id, ["open", "in_progress", "done"])
    {:noreply, assign(socket, tickets: tickets, ticket: nil)}
  end

  defp page_title(:show), do: "Show Board"
  defp page_title(:edit), do: "Edit Board"
end
