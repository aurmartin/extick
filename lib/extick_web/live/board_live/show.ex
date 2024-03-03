defmodule ExtickWeb.BoardLive.Show do
  use ExtickWeb, {:live_view, layout: :project}

  alias Extick.Tickets
  alias Extick.Boards
  alias Extick.Repo

  import ExtickWeb.BoardLive.Components

  @impl true
  def mount(params, _session, socket) do
    %{"id" => id} = params

    board = Boards.get_board!(id) |> Repo.preload(:project)
    tickets = Boards.get_tickets(board)

    {:ok, assign(socket, project: board.project, board: board, tickets: tickets, project_page: "backlog")}
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
    %{board: board, current_user: current_user} = socket.assigns

    ticket = %Tickets.Ticket{
      project_id: board.project.id,
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

    tickets = Boards.get_tickets(socket.assigns.board)

    {:noreply, assign(socket, tickets: tickets)}
  end

  defp page_title(:show), do: "Show Board"
  defp page_title(:edit), do: "Edit Board"
end
