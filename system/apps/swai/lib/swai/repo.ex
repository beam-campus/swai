defmodule Swai.Repo do
  use Ecto.Repo,
    otp_app: :swai,
    adapter: Ecto.Adapters.Postgres
end
