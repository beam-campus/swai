defmodule TrainSwarmProc.Aggregate do
  @moduledoc """
  This module defines the aggregate for the release right POC.
  """

defstruct [:agg_id, :state]

  alias Flags, as: Flags
  alias Commanded.Aggregate.Multi, as: Multi

  alias TrainSwarmProc.Aggregate, as: Aggregate
  alias TrainSwarmProc.Schema.States, as: States
  alias TrainSwarmProc.Schema.Root, as: Root

  alias TrainSwarmProc.Initialize.Cmd, as: Initialize
  alias TrainSwarmProc.Initialize.Evt, as: Initialized
  alias TrainSwarmProc.Initialize.Payload, as: InitializePayload

  alias TrainSwarmProc.Configure.Cmd, as: Configure
  alias TrainSwarmProc.Configure.Evt, as: Configured
  alias TrainSwarmProc.Initialize.Payload, as: ConfigurePayload

  @proc_unknown States.unknown()
  @proc_initialized States.initialized()
  @proc_configured States.configured()

  ##### INTERNALS #####

  defp raise_initialize_events(
         %Aggregate{} = aggregate,
         %Initialize{} = cmd
       ) do
    aggregate
    |> Multi.new()
    |> Multi.execute(&raise_initialized(&1, cmd))
    |> Multi.execute(&raise_configured(&1, cmd))
  end

  defp raise_initialized(
         _aggregate,
         %Initialize{} = cmd
       ) do
    {:ok,
     %Initialized{
       agg_id: cmd.agg_id,
       payload: cmd.payload
     }}
  end

  defp raise_configured(
         _aggregate,
         %Initialize{} = cmd
       ) do
    {:ok,
     %Configured{
       agg_id: cmd.agg_id,
       payload: cmd.payload
     }}
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

  ############### API ###############
  def execute(
        %Aggregate{agg_id: nil, state: nil} = aggregate,
        %Initialize{} = cmd
      ) do
    raise_initialize_events(aggregate, cmd)
  end

  def execute(%Aggregate{state: %Root{} = state} = aggregate, %Initialize{} = cmd) do
    cond do
      Flags.has?(state.status, States.unknown()) ->
        raise_initialize_events(aggregate, cmd)

      Flags.has?(state.status, States.initialized()) ->
        {:error, :already_initialized}

      true ->
        {:error, :already_initialized}
    end
  end

  def execute(
        %Aggregate{state: %Root{} = state} = aggregate,
        %Configure{} = cmd
      ) do
    cond do
      Flags.has?(state.status, States.initialized()) ->
        raise_configured(aggregate, cmd)

      Flags.has?(state.status, States.configured()) ->
        {:error, :already_configured}

      true ->
        {:error, :not_initialized}
    end
  end

  def apply(
        %Aggregate{state: nil} = _aggregate,
        %Initialized{} = evt
      ),
      do: %Aggregate{
        agg_id: evt.agg_id,
        state: %Root{
          id: evt.agg_id,
          status: @proc_initialized
        }
      }

  def apply(
        %Aggregate{state: %Root{} = state} = aggregate,
        %Configured{} = evt
      ) do
    %Aggregate{
      aggregate
      | state: %Root{
          state
          | status: Flags.set(state.status, @proc_configured),
            license_request: evt.payload
        }
    }
  end
end
