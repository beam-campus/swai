defmodule LogatronWeb.Dispatch.EdgePresence do
  use Phoenix.Presence,
  otp_app: :Logatron_web,
  pubsub_server: Logatron.PubSub
  @moduledoc """
  The EdgePresence is used to broadcast messages to all clients
  """
  require Logger







end
