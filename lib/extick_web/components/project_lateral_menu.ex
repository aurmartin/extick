defmodule Extick.Components.ProjectLateralMenu do
  use ExtickWeb, :component

  def render(assigns) do
    ~H"""
    <div class="fixed w-[200px] top-[60px] bottom-[0px] overflow-auto h-full bg-white border-r-2 border-gray-200">
      <div class="flex flex-col p-4">
        <h2 class="text-lg mb-4">{@project.name}</h2>

        <ul class="flex flex-col gap-1">
          <li>
            <.link
              class={[
                "p-2 rounded-sm block text-slate-900 font-semibold hover:bg-gray-200",
                if(@project_page == "current_iteration", do: "bg-gray-200")
              ]}
              href={~p"/projects/#{@project}/current_iteration"}
            >
              Current iteration
            </.link>
          </li>
          <li>
            <.link
              class={[
                "p-2 rounded-sm block text-slate-900 font-semibold hover:bg-gray-200",
                if(@project_page == "backlog", do: "bg-gray-200")
              ]}
              href={~p"/projects/#{@project}/backlog"}
            >
              Backlog
            </.link>
          </li>
          <li>
            <.link
              class={[
                "p-2 rounded-sm block text-slate-900 font-semibold hover:bg-gray-200",
                if(@project_page == "iterations", do: "bg-gray-200")
              ]}
              href={~p"/projects/#{@project}/iterations"}
            >
              Iterations
            </.link>
          </li>
          <li>
            <.link
              class={[
                "p-2 rounded-sm block text-slate-900 font-semibold hover:bg-gray-200",
                if(@project_page == "iterations", do: "bg-gray-200")
              ]}
              href={~p"/projects/#{@project}/reports"}
            >
              Reports
            </.link>
          </li>
          <li>
            <.link
              class={[
                "p-2 rounded-sm block text-slate-900 font-semibold hover:bg-gray-200",
                if(@project_page == "iterations", do: "bg-gray-200")
              ]}
              href={~p"/projects/#{@project}/settings"}
            >
              Settings
            </.link>
          </li>
        </ul>
      </div>
    </div>
    """
  end
end
