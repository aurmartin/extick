defmodule ExtickWeb.TicketLive.FormComponent do
  use ExtickWeb, :live_component

  alias Extick.Tickets

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage ticket records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="ticket-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <%= if @action == :new do %>
          <.input field={@form[:project_id]} type="hidden" />

          <.input field={@form[:type]} type="select" label="Type" options={type_select_options()} />
        <% else %>
          <.input field={@form[:type]} type="select" label="Type" disabled={true} options={type_select_options()} />
        <% end %>

        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:status]} type="select" label="Status" options={status_select_options()} />
        <.input field={@form[:priority]} type="select" label="Priority" options={priority_select_options()}/>

        <:actions>
          <.button phx-disable-with="Saving...">Save Ticket</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  defp status_select_options do
    Tickets.all_statuses() |> Enum.map(&{Tickets.format_status(&1), &1})
  end

  defp type_select_options do
    Tickets.all_types() |> Enum.map(&{Tickets.format_type(&1), &1})
  end

  defp priority_select_options do
    Tickets.all_priorities() |> Enum.map(&{Tickets.format_priority(&1), &1})
  end

  @impl true
  def update(%{ticket: ticket} = assigns, socket) do
    changeset = Tickets.change_ticket(ticket)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"ticket" => ticket_params}, socket) do
    changeset =
      socket.assigns.ticket
      |> Tickets.change_ticket(ticket_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"ticket" => ticket_params}, socket) do
    save_ticket(socket, socket.assigns.action, ticket_params)
  end

  defp save_ticket(socket, :edit, ticket_params) do
    case Tickets.update_ticket(socket.assigns.ticket, ticket_params) do
      {:ok, ticket} ->
        notify_parent({:saved, ticket})

        {:noreply,
         socket
         |> put_flash(:info, "Ticket updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_ticket(socket, :new, ticket_params) do
    case Tickets.create_ticket(ticket_params) |> IO.inspect() do
      {:ok, ticket} ->
        notify_parent({:saved, ticket})

        {:noreply,
         socket
         |> put_flash(:info, "Ticket created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
