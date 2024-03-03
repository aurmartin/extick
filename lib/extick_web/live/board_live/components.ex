defmodule ExtickWeb.BoardLive.Components do
  use ExtickWeb, :component

  alias Phoenix.LiveView.JS

  attr :status, :string
  attr :tickets, :list
  attr :board, :map

  def board_column(assigns) do
    tickets = Enum.filter(assigns.tickets, &(&1.status == assigns.status))
    assigns = assign(assigns, tickets: tickets)

    ~H"""
    <div class="rounded bg-gray-100 p-2 w-1/3 flex flex-col">
      <h2 class="text-xs text-gray-700 uppercase mb-2 p-1"><%= Extick.Tickets.format_status(@status) %></h2>

      <div id={@status} phx-hook="Sortable" data-list_id={@status} class="flex-grow">
        <%= for ticket <- @tickets do %>
          <div
            class="bg-white border border-transparent rounded shadow shadow-gray-400 p-2 transition cursor-pointer hover:bg-gray-100 hover:border-gray-400"
            phx-click={JS.patch(~p"/boards/#{@board}/edit_ticket/#{ticket}")} data-id={ticket.id}
          >
            <h3 class="text-sm"><%= ticket.title %></h3>
            <p class="capitalize text-sm mt-2"><%= Extick.Tickets.format_status(ticket.status) %></p>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
