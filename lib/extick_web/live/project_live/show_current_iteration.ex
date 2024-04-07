defmodule ExtickWeb.ProjectLive.ShowCurrentIteration do
  use ExtickWeb, {:live_view, layout: :project}

  alias Extick.{Tickets, Projects, Events, Repo}

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

    :ok = Tickets.tickets_subscribe(project)

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

    {:noreply, maybe_update_ticket(socket, ticket)}
  end

  @impl true
  def handle_info({ExtickWeb.TicketLive.FormComponent, {:updated, ticket}}, socket) do
    {:noreply, maybe_update_ticket(socket, ticket)}
  end

  def handle_info({ExtickWeb.TicketLive.FormComponent, {:created, ticket}}, socket) do
    {:noreply, maybe_add_to_assigns(socket, ticket)}
  end

  def handle_info({ExtickWeb.TicketLive.FormComponent, {:deleted, ticket}}, socket) do
    {:noreply, remove_ticket(socket, ticket)}
  end

  def handle_info({Extick.Tickets, %Events.TicketUpdated{ticket: ticket}}, socket) do
    {:noreply,
     socket
     |> maybe_add_to_assigns(ticket)
     |> maybe_update_ticket(ticket)
     |> maybe_remove_ticket(ticket)}
  end

  def handle_info({Extick.Tickets, %Events.TicketAdded{ticket: ticket}}, socket) do
    {:noreply, maybe_add_to_assigns(socket, ticket)}
  end

  def handle_info({Extick.Tickets, %Events.TicketDeleted{ticket: ticket}}, socket) do
    {:noreply, remove_ticket(socket, ticket)}
  end

  def handle_info({Extick.Tickets, %_event{comment: comment} = event}, socket) do
    send_update(ExtickWeb.TicketLive.FormComponent, id: comment.ticket_id, event: event)
    {:noreply, socket}
  end

  # Assigns update helpers

  defp maybe_add_to_assigns(socket, ticket) do
    if in_iteration?(socket, ticket) && !has_ticket?(socket, ticket) do
      ticket = Repo.preload(ticket, :assignee)
      update(socket, :tickets, &[ticket | &1])
    else
      socket
    end
  end

  defp has_ticket?(socket, ticket) do
    Enum.find_index(socket.assigns.tickets, &(&1.id == ticket.id))
  end

  defp in_iteration?(socket, ticket) do
    ticket.iteration_id == socket.assigns.iteration.id
  end

  defp maybe_update_ticket(socket, ticket) do
    if in_iteration?(socket, ticket) do
      update(socket, :tickets, fn tickets ->
        # TODO: Optimize preloading. Right now, we load assignee in maybe_add_to_assigns and here
        Enum.map(tickets, &if(&1.id == ticket.id, do: Repo.preload(ticket, :assignee), else: &1))
      end)
    else
      socket
    end
  end

  defp maybe_remove_ticket(socket, ticket) do
    if !in_iteration?(socket, ticket) do
      update(socket, :tickets, fn tickets ->
        Enum.reject(tickets, &(&1.id == ticket.id))
      end)
    else
      socket
    end
  end

  defp remove_ticket(socket, ticket) do
    update(socket, :tickets, fn tickets ->
      Enum.reject(tickets, &(&1.id == ticket.id))
    end)
  end

  defp page_title(:show), do: "Backlog"
  defp page_title(:new_ticket), do: "New Ticket"
  defp page_title(:edit_ticket), do: "Edit Ticket"
end
