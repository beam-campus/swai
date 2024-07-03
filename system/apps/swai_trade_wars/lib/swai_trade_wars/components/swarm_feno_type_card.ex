defmodule TradeWars.SwarmFenotypeCard do
  use TradeWarsWeb, :live_component

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :swarm_fenotype, %TradeWars.SwarmFenotype{})}
  end

end
