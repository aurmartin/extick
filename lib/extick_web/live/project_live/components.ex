defmodule ExtickWeb.ProjectLive.Components do
  use ExtickWeb, :component

  alias Phoenix.LiveView.JS

  attr :status, :string
  attr :tickets, :list
  attr :project, :map

  def board_column(assigns) do
    tickets =
      assigns.tickets
      |> Enum.filter(&(&1.status == assigns.status))
      |> Enum.sort_by(& &1.priority, :desc)

    assigns = assign(assigns, tickets: tickets)

    ~H"""
    <div class="rounded bg-gray-100 p-2 w-1/3 flex flex-col">
      <h2 class="text-xs text-gray-700 uppercase mb-2 p-1">
        <%= Extick.Tickets.format_status(@status) %>
      </h2>

      <div
        id={@status}
        phx-hook="BoardTicketDragDrop"
        data-list_id={@status}
        class="flex-grow flex flex-col gap-2"
      >
        <%= for ticket <- @tickets do %>
          <div
            class="bg-white border border-transparent rounded shadow shadow-gray-400 p-2 transition cursor-pointer hover:bg-gray-100 hover:border-gray-400"
            phx-click={JS.patch(~p"/projects/#{@project}/current_iteration/edit_ticket/#{ticket}")}
            data-id={ticket.id}
          >
            <div class="flex mb-1 items-top">
              <div class="text-zinc-500 text-sm"><%= ticket.id %></div>

              <div class={[
                "ml-auto uppercase text-xs font-bold",
                case ticket.type do
                  "story" -> "text-green-600"
                  "enabler" -> "text-sky-500"
                  "bug" -> "text-red-600"
                end
              ]}>
                <%= ticket.type %>
              </div>
            </div>

            <h3 class="text-sm"><%= ticket.title %></h3>

            <%= if ticket.assignee do %>
              <img src={ticket.assignee.avatar_url} alt={ticket.assignee.name} class="w-6 h-6 rounded-full mt-1" />
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
