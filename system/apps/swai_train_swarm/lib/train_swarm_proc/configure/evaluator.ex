defmodule TrainSwarmProc.Configure.Evaluator do
  @behaviour Commanded.Commands.Handler

  alias TrainSwarmProc.Configure.Cmd.V1, as: Configure
  alias TrainSwarmProc.Configure.Evt.V1, as: Configured
  alias TrainSwarmProc.Schema.Root, as: Root

  import Flags

  @proc_initialized Schema.SwarmTraining.Status.initialized()

  def handle(
        %{state: %Root{} = state} = aggregate,
        %Configure{} = cmd
      ) do
    cond do
      state.status
      |> has?(@proc_initialized) ->
        raise_configured(aggregate, cmd)

      true ->
        {:error, :not_initialized}
    end
  end

  defp raise_configured(
         _aggregate,
         %Configure{} = cmd
       ) do
    {
      :ok,
      %Configured{
        agg_id: cmd.agg_id,
        payload: cmd.payload
      }
    }
  end
end
