defmodule ExtickWeb.TicketLive.FormComponent do
  alias Extick.Events
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
          <.input field={@form[:type]} type="select" label="Type" options={type_select_options()} />
        <% else %>
          <.input
            field={@form[:type]}
            type="select"
            label="Type"
            disabled={true}
            options={type_select_options()}
          />
        <% end %>

        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input
          field={@form[:status]}
          type="select"
          label="Status"
          options={status_select_options(assigns)}
        />
        <.input
          field={@form[:priority]}
          type="select"
          label="Priority"
          options={priority_select_options()}
        />

        <:actions>
          <.button phx-disable-with="Deleting..." phx-target={@myself} phx-click={JS.push("delete")}>
            Delete Ticket
          </.button>
          <.button phx-disable-with="Saving...">Save Ticket</.button>
        </:actions>
      </.simple_form>

      <%= if @action == :edit do %>
        <h2 class="mt-4 text-lg font-bold">Comments</h2>
        <.simple_form
          for={@comment_form}
          id="comment-form"
          phx-target={@myself}
          phx-change="validate_comment"
          phx-submit="save_comment"
        >
          <.input field={@comment_form[:content]} type="textarea" placeholder="New comment" rows="2" />
          <.button phx-disable-with="Saving...">Save</.button>
        </.simple_form>

        <%= for comment <- @comments do %>
          <div class="mt-4">
            <p class="text-sm mb-1">
              <%= comment.author.name %>, <.local_time id={comment.id} date={comment.inserted_at} />
            </p>
            <p class="rounded p-2 bg-gray-100"><%= comment.content %></p>
          </div>
        <% end %>
      <% end %>
    </div>
    """
  end

  defp status_select_options(assigns) do
    Tickets.statuses(assigns.project) |> Enum.map(&{Tickets.format_status(&1), &1})
  end

  defp type_select_options do
    Tickets.types() |> Enum.map(&{Tickets.format_type(&1), &1})
  end

  defp priority_select_options do
    Tickets.priorities() |> Enum.map(&{Tickets.format_priority(&1), &1})
  end

  @impl true
  def update(%{ticket: ticket} = assigns, socket) do
    comments = Tickets.list_comments(ticket.id)
    changeset = Tickets.change_ticket(ticket)
    comment_changeset = Tickets.change_comment(%Tickets.Comment{})

    :ok = Tickets.comments_subscribe(ticket)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:comments, comments)
     |> assign(:comment_form, to_form(comment_changeset))
     |> assign_form(changeset)}
  end

  def update(%{event: %Events.CommentAdded{comment: comment}}, socket) do
    comments =
      [comment | socket.assigns.comments]
      |> Enum.uniq_by(&(&1.id))
      |> Enum.sort(&(&1.inserted_at > &2.inserted_at))

    {:ok, assign(socket, :comments, comments)}
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

  def handle_event("delete", _, socket) do
    case Tickets.delete_ticket(socket.assigns.ticket) do
      {:ok, ticket} ->
        notify_parent({:deleted, ticket})

        {:noreply,
         socket
         |> put_flash(:info, "Ticket deleted successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, _} ->
        {:noreply, socket |> put_flash(:error, "Ticket could not be deleted")}
    end
  end

  def handle_event("validate_comment", %{"comment" => comment_params}, socket) do
    comment_form =
      %Tickets.Comment{}
      |> Tickets.change_comment(comment_params)
      |> to_form()

    {:noreply, assign(socket, :comment_form, comment_form)}
  end

  def handle_event("save_comment", %{"comment" => comment_params}, socket) do
    ticket = socket.assigns.ticket
    author = socket.assigns.current_user

    case Tickets.create_comment(ticket, author, comment_params) do
      {:ok, _comment} ->
        comments = Tickets.list_comments(ticket.id)
        comment_changeset = Tickets.change_comment(%Tickets.Comment{})

        socket =
          socket
          |> assign(:comments, comments)
          |> assign(:comment_form, to_form(comment_changeset))

        {:noreply, socket}

      {:error, _} ->
        {:noreply, socket |> put_flash(:error, "Comment could not be saved")}
    end
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
    %{project: project} = socket.assigns

    case Tickets.create_ticket(project, ticket_params) do
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
