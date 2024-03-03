defmodule ExtickWeb.BoardLive.Show do
  use ExtickWeb, :live_view

  alias Extick.Boards
  alias Extick.Repo

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    board = Boards.get_board!(id) |> Repo.preload(:project)
    tickets = Boards.get_tickets(board)

    IO.inspect(tickets, label: "tickets")

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:board, board)
     |> assign(:tickets, tickets)}
  end

  defp page_title(:show), do: "Show Board"
  defp page_title(:edit), do: "Edit Board"
end
