defmodule SwaiWeb.Dispatch.EdgePresence do
  use Phoenix.Presence,
  otp_app: :Swai_web,
  pubsub_server: Swai.PubSub
  @moduledoc """
  The EdgePresence is used to broadcast messages to all clients
  """
  require Logger







end
