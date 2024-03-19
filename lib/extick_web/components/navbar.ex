defmodule ExtickWeb.Components.Navbar do
  use ExtickWeb, :component

  attr :current_user, :map
  attr :current_org, :map

  def navbar(%{current_user: current_user} = assigns) when not is_nil(current_user) do
    ~H"""
    <ul class="fixed top-0 left-0 z-10 w-full flex items-center gap-4 h-[60px] px-4 sm:px-6 lg:px-8 border-b-2 border-slate-300 bg-white">
      <%= if @current_org do %>
        <li class="text-slate-900"><%= @current_org.name %></li>
        <.navbar_link href={~p"/projects"}>Projects</.navbar_link>
      <% end %>

      <li class="text-slate-900 ml-auto">
        <%= @current_user.email %>
      </li>

      <.navbar_link href={~p"/users/settings"}>Settings</.navbar_link>
      <.navbar_link href={~p"/users/log_out"} method="delete">Log out</.navbar_link>
    </ul>
    """
  end

  def navbar(assigns) do
    ~H"""
    <ul class="fixed top-0 left-0 z-10 w-full flex items-center gap-4 h-[60px] px-4 sm:px-6 lg:px-8 border-b-2 border-slate-300 bg-white">
      <li class="text-slate-900 mr-auto">
        <.link href={~p"/"} class="text-slate-900 font-semibold hover:text-slate-500">
          ExTick
        </.link>
      </li>

      <.navbar_link href={~p"/users/register"}>Register</.navbar_link>
      <.navbar_link href={~p"/users/log_in"}>Log in</.navbar_link>
    </ul>
    """
  end

  attr :href, :string
  attr :method, :string, default: "get"
  slot :inner_block, required: true

  defp navbar_link(assigns) do
    ~H"""
    <li>
      <.link href={@href} method={@method} class="text-slate-900 font-semibold hover:text-slate-500">
        <%= render_slot(@inner_block) %>
      </.link>
    </li>
    """
  end
end
