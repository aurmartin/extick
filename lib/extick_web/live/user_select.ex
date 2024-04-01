defmodule ExtickWeb.UserSelect do
  use ExtickWeb, :live_component

  alias Extick.Accounts

  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []

  @impl true
  def render(assigns) do
    ~H"""
    <div phx-feedback-for={@name} phx-hook="Select" id={@id}>
      <.label for={@id}><%= @label %></.label>

      <div class="relative">
        <div class="relative">
          <input
            type="hidden"
            id={@id <> "_value_input"}
            name={@name}
            value={if @selected, do: @selected.id}
          />

          <input
            form="disabled"
            id={@id <> "_input"}
            type="text"
            autocomplete="off"
            value={if @selected, do: @selected.name}
            class={[
              "py-1 px-2 mt-1 block w-full rounded border focus:ring-0 sm:text-sm sm:leading-6",
              "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400",
              "cursor-default",
              @errors == [] && "border-zinc-300 focus:border-zinc-400",
              @errors != [] && "border-rose-400 focus:border-rose-400"
            ]}
          />

          <div id={@id <> "_loader"} class="absolute right-2 top-0 bottom-0 flex items-center hidden">
            <.icon name="hero-arrow-path" class="block h-4 w-4 animate-spin text-gray-600" />
          </div>
        </div>

        <div
          id={@id <> "_select"}
          class="absolute w-full top-[100%] border border-zinc-300 rounded shadow-md my-2 bg-white hidden"
        >
          <div class="relative max-height-[300px] overflow-y-auto py-1">
            <%= if Enum.empty?(@users) do %>
              <p class="p-2 text-sm">No results</p>
            <% else %>
              <%= for user <- @users do %>
                <div
                  class="p-1 cursor-default hover:bg-gray-200 text-sm flex items-center"
                  data-id={user.id}
                  data-text={user.name}
                >
                  <img src={user.avatar_url} alt={user.name} class="w-5 h-5 mr-1" />
                  <%= user.name %>
                </div>
              <% end %>
            <% end %>
          </div>
        </div>
      </div>

      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    %{field: field, org: org} = assigns

    socket =
      socket
      |> assign(assigns)
      |> assign(field: nil, id: assigns.id || field.id)
      |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
      |> assign_new(:name, fn -> field.name end)
      |> assign_new(:value, fn -> field.value end)
      |> assign_new(:users, fn ->
        Accounts.search_users_by_org_and_name(org)
      end)

    selected = Enum.find(socket.assigns.users, &(&1.id == field.value))
    socket = assign(socket, :selected, selected)

    {:ok, socket}
  end

  @impl true
  def handle_event("change", %{"value" => value}, socket) do
    users = Accounts.search_users_by_org_and_name(socket.assigns.org, value)
    {:noreply, assign(socket, users: users)}
  end
end
