defmodule ErlUtils do

  def count_messages do
      :erlang.processes()
      |> Enum.reduce(0,
      fn(pid, acc) ->
      {_, message_queue} =
        :erlang.process_info(pid, :message_queue_len)
      acc + message_queue + 1
    end)
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


end
