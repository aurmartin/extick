defmodule Extick.Repo do
  use Ecto.Repo,
    otp_app: :extick,
    adapter: Ecto.Adapters.Postgres
end
