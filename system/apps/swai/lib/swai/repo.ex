defmodule Swai.Repo do
  use Ecto.Repo,
    otp_app: :swai,
    adapter: Ecto.Adapters.SQLite3
end
