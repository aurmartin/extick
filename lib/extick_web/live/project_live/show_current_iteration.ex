defmodule ExtickWeb.ProjectLive.ShowCurrentIteration do
  use ExtickWeb, {:live_view, layout: :project}

  alias Extick.Tickets
  alias Extick.Projects

  import ExtickWeb.ProjectLive.Components

  @impl true
  def mount(params, _session, socket) do
    %{"id" => id} = params

    project = Projects.get_project!(id)
    iteration = Projects.find_current_iteration(project)
    tickets =
      if iteration do
        Tickets.list_tickets_by_iteration(iteration.id)
      else
        []
      end

    {:ok,
     assign(socket,
       project: project,
       iteration: iteration,
       tickets: tickets,
       project_page: "current_iteration"
     )}
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
    ticket =
      socket.assigns.tickets
      |> Enum.find(&(&1.id == ticket_id))
      |> Map.put(:project, socket.assigns.project)

    assign(socket, page_title: page_title(socket.assigns.live_action), ticket: ticket)
  end

  defp apply_action(socket, :new_ticket, _params) do
    %{project: project, current_user: current_user} = socket.assigns

    ticket = %Tickets.Ticket{
      project: project,
      priority: 3,
      reporter_id: current_user.id
    }

    assign(socket, page_title: page_title(socket.assigns.live_action), ticket: ticket)
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

    ticket =
      socket.assigns.tickets
      |> Enum.find(&(&1.id == id))
      |> Map.put(:project, socket.assigns.project)

    {:ok, ticket} = Tickets.update_ticket(ticket, %{status: new_status})

    tickets = Enum.map(socket.assigns.tickets, fn t -> if t.id == id, do: ticket, else: t end)

    {:noreply, assign(socket, tickets: tickets)}
  end

  @impl true
  def handle_info({ExtickWeb.TicketLive.FormComponent, {:saved, _ticket}}, socket) do
    {:noreply, assign(socket, ticket: nil)}
  end

  def handle_info({ExtickWeb.TicketLive.FormComponent, {:deleted, ticket}}, socket) do
    tickets = socket.assigns.tickets |> Enum.reject(&(&1.id == ticket.id))
    {:noreply, assign(socket, tickets: tickets, ticket: nil)}
  end

  defp page_title(:show), do: "Backlog"
  defp page_title(:new_ticket), do: "New Ticket"
  defp page_title(:edit_ticket), do: "Edit Ticket"
end
