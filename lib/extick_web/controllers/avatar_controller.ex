defmodule ExtickWeb.AvatarController do
  use ExtickWeb, :controller

  def show(conn, params) do
    %{"color" => color, "name" => name} = params
    initials = String.split(name, " ") |> Enum.map_join("", &String.at(&1, 0))

    svg = """
    <svg xmlns="http://www.w3.org/2000/svg" width="64px" height="64px" viewBox="0 0 64 64">
      <circle cx="32" cy="32" r="32" width="64" height="64" fill="#{color}" />
      <text
        x="50%"
        y="50%"
        text-anchor="middle"
        dominant-baseline="middle"
        font-size="28"
        font-weight="400"
        dy=".1em"
        style="color: #222; line-height: 1; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen', 'Ubuntu', 'Fira Sans', 'Droid Sans', 'Helvetica Neue', sans-serif;"
        fill="white"
        font-family="Arial, sans-serif"
      >
        #{initials}
      </text>
    </svg>
    """

    conn
    |> put_resp_content_type("image/svg+xml")
    |> send_resp(200, svg)
  end
end
