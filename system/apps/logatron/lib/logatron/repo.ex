defmodule Logatron.Repo do
  use Ecto.Repo,
    otp_app: :logatron,
    adapter: Ecto.Adapters.Postgres
end
