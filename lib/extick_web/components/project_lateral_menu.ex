defmodule Extick.Components.ProjectLateralMenu do
  use ExtickWeb, :component

  def render(assigns) do
    ~H"""
    <div class="flex flex-col min-w-[200px] p-4 border-r-2">
      <h2 class="text-lg mb-4"><%= @project.name %></h2>

      <ul class="flex flex-col gap-1">
        <li>
          <.link
            class={[
              "p-2 rounded block text-slate-900 font-semibold hover:bg-gray-200",
              (if @project_page == "current_sprint", do: "bg-gray-200")
            ]}
            href={~p"/boards/#{@project.default_board_id}"}
          >
            Current iteration
          </.link>
        </li>
        <li>
          <.link
            class={[
              "p-2 rounded block text-slate-900 font-semibold hover:bg-gray-200",
              (if @project_page == "backlog", do: "bg-gray-200")
            ]}
            href={~p"/boards/#{@project.default_board_id}"}
          >
            Backlog
          </.link>
        </li>
        <li>
          <.link
            class={[
              "p-2 rounded block text-slate-900 font-semibold hover:bg-gray-200",
              (if @project_page == "iterations", do: "bg-gray-200")
            ]}
            href={~p"/boards/#{@project.default_board_id}"}
          >
            Iterations
          </.link>
        </li>
        <li>
          <.link
            class={[
              "p-2 rounded block text-slate-900 font-semibold hover:bg-gray-200",
              (if @project_page == "iterations", do: "bg-gray-200")
            ]}
            href={~p"/boards/#{@project.default_board_id}"}
          >
            Reports
          </.link>
        </li>
        <li>
          <.link
            class={[
              "p-2 rounded block text-slate-900 font-semibold hover:bg-gray-200",
              (if @project_page == "iterations", do: "bg-gray-200")
            ]}
            href={~p"/boards/#{@project.default_board_id}"}
          >
            Settings
          </.link>
        </li>
      </ul>
    </div>
    """
  end
end