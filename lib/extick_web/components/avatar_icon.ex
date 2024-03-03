defmodule ExtickWeb.Components.AvatarIcon do
  use ExtickWeb, :component

  attr :user, :map
  attr :rest, :global

  def avatar_icon(assigns) do
    initials = assigns.user.name |> String.split(" ") |> Enum.map(&String.at(&1, 0)) |> Enum.join("")
    assigns = assign(assigns, initials: initials)

    render_default_initials(assigns)
  end

  defp render_default_initials(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      xmlns:xlink="http://www.w3.org/1999/xlink"
      width="24px"
      height="24px"
      viewBox="0 0 24 24"
      version="1.1"
      {@rest}
    >
      <circle fill="#ddd" cx="12" width="24" height="24" cy="12" r="12" />
      <text
        x="50%"
        y="50%"
        style="color: #222; font-size: 12px; font-weight: bold;"
        alignment-baseline="middle"
        text-anchor="middle"
        font-size="28"
        font-weight="400"
        dy=".1em"
        dominant-baseline="middle"
        fill="#222"
      >
        <%= @initials %>
      </text>
    </svg>
    """
  end
end
