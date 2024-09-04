defmodule Hive.Emitter do
  alias Hive.Facts, as: HiveFacts
  alias Hive.Init, as: HiveInit
  alias Edge.Client, as: Client

  def emit_hive_initialized(%HiveInit{edge_id: edge_id} = hive_init),
    do:
      Client.publish(
        edge_id,
        HiveFacts.hive_initialized_v1(),
        %{hive_init: hive_init}
      )

  def emit_hive_occupied(%HiveInit{edge_id: edge_id} = hive_init),
    do:
      Client.publish(
        edge_id,
        HiveFacts.hive_occupied_v1(),
        %{hive_init: hive_init}
      )

  def emit_hive_vacated(%HiveInit{edge_id: edge_id} = hive_init),
    do:
      Client.publish(
        edge_id,
        HiveFacts.hive_vacated_v1(),
        %{hive_init: hive_init}
      )
end
