defmodule ExtickWeb.BoardLive.Show do
  use ExtickWeb, {:live_view, layout: :app_wide}

  alias Extick.Tickets
  alias Extick.Boards
  alias Extick.Repo

  import ExtickWeb.BoardLive.Components

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    board = Boards.get_board!(id) |> Repo.preload(:project)
    tickets = Boards.get_tickets(board)

    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:board, board)
    |> assign(:tickets, tickets)
  end

  defp apply_action(socket, :edit_ticket, %{"id" => id, "ticket_id" => ticket_id}) do
    board = Boards.get_board!(id) |> Repo.preload(:project)
    tickets = Boards.get_tickets(board)
    ticket = Tickets.get_ticket!(ticket_id)

    socket
    |> assign(:page_title, "Edit Ticket")
    |> assign(:board, board)
    |> assign(:ticket, ticket)
    |> assign(:tickets, tickets)
  end

  defp apply_action(socket, :new_ticket, %{"id" => id}) do
    board = Boards.get_board!(id) |> Repo.preload(:project)
    tickets = Boards.get_tickets(board)

    ticket = %Tickets.Ticket{
      project_id: board.project.id,
      priority: 3,
      reporter_id: socket.assigns.current_user.id,
    }

    socket
    |> assign(:page_title, "New Ticket")
    |> assign(:board, board)
    |> assign(:ticket, ticket)
    |> assign(:tickets, tickets)
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
