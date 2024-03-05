defmodule ExtickWeb.ProjectLive.ShowBacklog do
  use ExtickWeb, {:live_view, layout: :project}

  alias Extick.Tickets
  alias Extick.Projects

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
    ticket = Tickets.get_ticket!(ticket_id)
    assign(socket, page_title: page_title(socket.assigns.live_action), ticket: ticket)
  end

  defp apply_action(socket, :new_ticket, _params) do
    %{project: project, current_user: current_user} = socket.assigns

    ticket = %Tickets.Ticket{
      project_id: project.id,
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

    ticket = Tickets.get_ticket!(id)
    {:ok, _ticket} = Tickets.update_ticket(ticket, %{iteration_id: new_iteration})

    {:noreply, update_tickets(socket)}
  end

  def handle_event("start_iteration", %{"id" => iteration_id}, socket) do
    iteration = Projects.get_iteration!(iteration_id)
    {:ok, _iteration} = Projects.update_iteration(iteration, %{status: "active"})
    {:noreply, update_iterations(socket)}
  end

  def handle_event("complete_iteration", %{"id" => iteration_id}, socket) do
    iteration = Projects.get_iteration!(iteration_id)
    {:ok, _iteration} = Projects.complete_iteration(iteration)
    {:noreply, socket |> update_tickets() |> update_iterations()}
  end

  @impl true
  def handle_info({ExtickWeb.TicketLive.FormComponent, {:saved, _ticket}}, socket) do
    {:noreply, socket |> update_tickets() |> assign(ticket: nil)}
  end

  def handle_info({ExtickWeb.ProjectLive.IterationFormComponent, {:saved, _iteration}}, socket) do
    iterations =
      Projects.list_iterations_by_project_and_statuses(socket.assigns.project.id, [
        "planned",
        "active"
      ])

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
