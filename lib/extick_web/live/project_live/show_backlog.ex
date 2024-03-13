defmodule ExtickWeb.ProjectLive.ShowBacklog do
  use ExtickWeb, {:live_view, layout: :project}

  alias Extick.Tickets
  alias Extick.Projects

  defmodule TicketListItem do
    use ExtickWeb, :live_component

    def render(assigns) do
      ~H"""
      <div
        data-id={@ticket.id}
        class="flex mt-[-1px] p-2 text-sm cursor-pointer hover:bg-gray-100 border-y border-zinc-400"
        phx-click={JS.patch(~p"/projects/#{@project}/backlog/edit_ticket/#{@ticket.id}")}
      >
        <div class="mr-2 text-zinc-500"><%= @ticket.id %></div>
        <div><%= @ticket.title %></div>

        <div class="ml-auto">
          <div class={[
            "rounded py-0.5 px-1 text-sm",
            case @ticket.status do
              "in_progress" -> "bg-blue-200"
              "done" -> "bg-green-300"
              _ -> "bg-gray-200"
            end
          ]}>
            <%= Extick.Tickets.format_status(@ticket.status) %>
          </div>
        </div>
      </div>
      """
    end
  end

  @impl true
  def mount(params, _session, socket) do
    %{"id" => id} = params

    project = Projects.get_project!(id)

    socket =
      socket
      |> assign(project: project)
      |> update_tickets()
      |> update_iterations()

    {:ok, assign(socket, project_page: "backlog")}
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

  defp apply_action(socket, :new_iteration, _params) do
    %{project: project} = socket.assigns

    iteration = %Projects.Iteration{
      start_date: Date.utc_today(),
      end_date: Date.utc_today() |> Date.add(7),
      project_id: project.id,
      status: "planned"
    }

    assign(socket, page_title: page_title(socket.assigns.live_action), iteration: iteration)
  end

  @impl true
  def handle_event("change_ticket_iteration", params, socket) do
    %{
      "id" => id,
      "newIndex" => _new_index,
      "newIteration" => new_iteration,
      "oldIndex" => _old_index,
      "oldIteration" => _old_iteration
    } = params

    ticket = socket.assigns.tickets |> Enum.find(&(&1.id == id))
    {:ok, ticket} = Tickets.update_ticket(ticket, %{iteration_id: new_iteration})
    tickets = socket.assigns.tickets |> Enum.map(&if &1.id == id, do: ticket, else: &1)

    {:noreply, assign(socket, tickets: tickets)}
  end

  def handle_event("start_iteration", %{"id" => iteration_id}, socket) do
    iteration = socket.assigns.iterations |> Enum.find(&(&1.id == iteration_id))
    {:ok, iteration} = Projects.update_iteration(iteration, %{status: "active"})

    iterations =
      socket.assigns.iterations |> Enum.map(&if &1.id == iteration_id, do: iteration, else: &1)

    {:noreply, assign(socket, iterations: iterations)}
  end

  def handle_event("complete_iteration", %{"id" => iteration_id}, socket) do
    iteration = socket.assigns.iterations |> Enum.find(&(&1.id == iteration_id))
    {:ok, iteration} = Projects.complete_iteration(iteration)

    iterations =
      socket.assigns.iterations |> Enum.map(&if &1.id == iteration_id, do: iteration, else: &1)

    {:noreply, socket |> assign(iterations: iterations) |> update_tickets()}
  end

  @impl true
  def handle_info({ExtickWeb.TicketLive.FormComponent, {:saved, ticket}}, socket) do
    tickets = socket.assigns.tickets |> Enum.map(&if &1.id == ticket.id, do: ticket, else: &1)
    {:noreply, assign(socket, tickets: tickets, ticket: nil)}
  end

  def handle_info({ExtickWeb.TicketLive.FormComponent, {:deleted, ticket}}, socket) do
    tickets = socket.assigns.tickets |> Enum.reject(&(&1.id == ticket.id))
    {:noreply, assign(socket, tickets: tickets, ticket: nil)}
  end

  def handle_info({ExtickWeb.ProjectLive.IterationFormComponent, {:saved, iteration}}, socket) do
    iterations =
      socket.assigns.iterations |> Enum.map(&if &1.id == iteration.id, do: iteration, else: &1)

    {:noreply, assign(socket, iterations: iterations, iteration: nil)}
  end

  defp update_iterations(socket) do
    iterations =
      Projects.list_iterations_by_project_and_statuses(socket.assigns.project.id, [
        "planned",
        "active"
      ])

    assign(socket, iterations: iterations)
  end

  defp update_tickets(socket) do
    tickets = Tickets.list_tickets_by_project(socket.assigns.project.id)
    assign(socket, tickets: tickets)
  end

  defp page_title(:show), do: "Backlog"
  defp page_title(:new_ticket), do: "New Ticket"
  defp page_title(:edit_ticket), do: "Edit Ticket"
  defp page_title(:new_iteration), do: "New Iteration"
end
