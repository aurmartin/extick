defmodule ExtickWeb.TicketLive.FormComponent do
  alias Extick.Events
  use ExtickWeb, :live_component

  alias Extick.Tickets

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} id="ticket-form" phx-target={@myself} phx-change="validate" phx-submit="save">
        <div class="flex mb-4">
          <div class="w-2/3 space-y-4 pr-8">
            <.input field={@form[:title]} type="ticket-title" phx-debounce="300" placeholder="Title" />

            <div class="grid grid-cols-2 gap-4">
              <.input
                field={@form[:type]}
                type="select"
                label="Type"
                disabled={@action == :edit}
                options={type_select_options()}
              />

              <.input
                field={@form[:status]}
                type="select"
                label="Status"
                options={status_select_options(assigns)}
              />
            </div>

            <.input
              field={@form[:description]}
              phx-debounce="300"
              type="textarea"
              label="Description"
            />
          </div>

          <div class="w-1/3 space-y-4 pt-4 px-8">
            <p class="">Additional Fields</p>
            <.input
              field={@form[:priority]}
              label="Priority"
              type="select"
              options={priority_select_options()}
            />

            <.live_component
              parent={@myself}
              id={@form[:assignee_id].id}
              org={@current_org}
              module={ExtickWeb.UserSelect}
              label="Assignee"
              field={@form[:assignee_id]}
            />
          </div>
        </div>

        <%= if @action == :edit do %>
          <.button phx-disable-with="Saving..." phx-target={@myself} phx-click={JS.push("delete")}>
            Delete Ticket
          </.button>
        <% end %>

        <%= if @action == :new do %>
          <.button phx-disable-with="Saving...">Save Ticket</.button>
        <% end %>
      </.form>

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
    comments = Tickets.list_comments(ticket)
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
      |> Enum.uniq_by(& &1.id)
      |> Enum.sort(&(&1.inserted_at > &2.inserted_at))

    {:ok, assign(socket, :comments, comments)}
  end

  @impl true
  def handle_event("validate", %{"ticket" => ticket_params}, socket) do
    changeset =
      socket.assigns.ticket
      |> Tickets.change_ticket(ticket_params)
      |> Map.put(:action, :validate)

    if socket.assigns.action == :edit do
      save_ticket(socket, socket.assigns.action, ticket_params)
    end

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
        comments = Tickets.list_comments(ticket)
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
        notify_parent({:updated, ticket})

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
        notify_parent({:created, ticket})

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
