defmodule ErlUtils do
  def count_messages do
    :erlang.processes()
    |> Enum.reduce(
      0,
      fn pid, acc ->
        case :erlang.process_info(pid, :message_queue_len) do
          {:message_queue_len, queue_len} ->
            acc + queue_len + 1

          _ ->
            acc
        end
      end
    )
  end

  def total_messages do
    :erlang.processes()
    |> Enum.map(&Process.info(&1, :message_queue_len))
    |> Enum.map(fn
      {:message_queue_len, len} -> len
      _ -> 0
    end)
    |> Enum.sum()
  end

  def total_processes do
    :erlang.processes()
    |> Enum.count()
  end
end
