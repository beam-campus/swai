defmodule Born2Died.HealthRules do
  alias Swai.Limits
  alias Born2Died.State, as: LifeState
  alias Schema.Vitals, as: Vitals

  require :math

  @default_ticks_per_year Limits.ticks_per_year()

  def live(%LifeState{} = life_state) do
    %LifeState{
      life_state
      | status: calc_status(life_state),
        vitals: calc_vitals(life_state),
        ticks: life_state.ticks + 1
    }
  end

  defp calc_status(%LifeState{vitals: vitals} = _life_state)
  when vitals.health > 0,
  do:  "alive"

  defp calc_status(%LifeState{} = _life_state),
    do: "dead"

  defp calc_vitals(%LifeState{vitals: %Vitals{} = vitals} = life_state) do
    %{
      vitals
      | health: calc_hp(life_state),
        energy: calc_energy(life_state),
        heath: calc_heath(life_state),
        age: calc_age(life_state)
    }
  end

  defp calc_age(%LifeState{ticks: ticks} = life_state)
       when rem(ticks, @default_ticks_per_year) == 0,
       do: life_state.vitals.age + 1

  defp calc_age(%LifeState{} = life_state),
    do: life_state.vitals.age

  defp calc_heath(%LifeState{} = life_state) do
    life_state.vitals.heath - 1
  end

  defp calc_energy(%LifeState{} = life_state) do
    life_state.vitals.energy - 1
  end

  defp calc_hp(%LifeState{} = life_state) do
    life_state.vitals.health - 1
  end
end
