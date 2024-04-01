defmodule ExtickWeb.ProjectLive.IterationFormComponent do
  use ExtickWeb, :live_component

  alias Extick.Projects

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        for={@form}
        id="project-iteration-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:project_id]} type="hidden" />
        <.input field={@form[:status]} type="hidden" />

        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:start_date]} type="date" label="Start date" />
        <.input field={@form[:end_date]} type="date" label="End date" />

        <:actions>
          <.button phx-disable-with="Saving...">Create iteration</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{iteration: iteration, action: :new} = assigns, socket) do
    changeset = Projects.Iteration.creation_changeset(iteration, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"iteration" => iteration_params}, socket) do
    changeset =
      socket.assigns.iteration
      |> Projects.Iteration.creation_changeset(iteration_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"iteration" => iteration_params}, socket) do
    save_iteration(socket, socket.assigns.action, iteration_params)
  end

  defp save_iteration(socket, :edit, iteration_params) do
    case Projects.update_iteration(socket.assigns.iteration, iteration_params) do
      {:ok, iteration} ->
        notify_parent({:updated, iteration})

        {:noreply,
         socket
         |> put_flash(:info, "Project updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_iteration(socket, :new, iteration_params) do
    case Projects.create_iteration(iteration_params) do
      {:ok, iteration} ->
        notify_parent({:created, iteration})

        {:noreply,
         socket
         |> put_flash(:info, "Iteration created successfully")
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
