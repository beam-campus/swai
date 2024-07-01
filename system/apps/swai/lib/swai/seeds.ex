# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Swai.Repo.insert!(%Swai.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
defmodule Swai.Seeds do
  alias Swai.Repo, as: Repo
  alias Schema.Biotope, as: Biotope

  def seed_biotopes do

    case Repo.get_by(Biotope, name: "Traders of Macao") do
      nil ->
        Repo.insert!(%Biotope{
          name: "Traders of Macao",
          description:
            "Traders of Macao is a darwinian ecosystem that allows for swarms to trade resources and stocks.
        Individual worker bees are rewarded for making a profit and evolutionary selection happens by simple ranking.
        The ecosystem is fed by stock tickers and the bees can trade stocks, commodities, and cryptocurrencies.",
          image_url: "/images/trade_wars1.jpg",
          theme: "Finance",
          tags: "finance, stock market, trade, profit, cash",
          difficulty: 3,
          objective: "The objective is to make a profit.",
          environment: "The environment is a stock market.",
          challenges: "The challenges are to predict the market and make the right trades.",
          is_active?: true,
          biotope_type: "Swarm vs Environment",
          is_realistic?: true
        })

      _ ->
        :ok
    end


    case Repo.get_by(Biotope, name: "Performance Art Competition") do
      nil ->
        Repo.insert!(%Biotope{
          name: "Performance Art Competition",
          description:
            "Performance Art Competition is a simulation of a performance art competition.
      The ecosystem is fed by performance data and the objective is to win the competition.",
          image_url: "/images/performance_wars1.jpg",
          theme: "Art",
          tags: "performance, art, competition, music, dance",
          difficulty: 3,
          objective: " Create and perform the most impressive synchronized routines.",
          environment: "A performance stage with various props and settings.",
          challenges: "Designing intricate routines, coordinating swarm movements, and timing performances perfectly.
          Audience reactions and judges' scores determine the winner.",
          is_active?: false,
          biotope_type: "Swarm vs Environment",
          is_realistic?: false
        })

      _ ->
        :ok
    end

    case Repo.get_by(Biotope, name: "Pollution Cleanup") do
      nil ->
        Repo.insert!(%Biotope{
          name: "Pollution Cleanup",
          description:
            "Pollution Cleanup is a simulation of a pollution cleanup system.
      The ecosystem is fed by pollution data and the objective is to clean up the pollution.",
          image_url: "/images/pollution_wars1.jpg",
          theme: "Environment",
          tags: "pollution, cleanup, environment, climate, ecology",
          difficulty: 3,
          objective: "Clean up pollutants from a contaminated environment.",
          environment: "A polluted landscape with various types of pollutants.",
          challenges: "The challenges are to clean up the pollution.",
          is_active?: false,
          biotope_type: "Swarm vs Environment",
          is_realistic?: false
        })

      _ ->
        :ok
    end

    case Repo.get_by(Biotope, name: "Weather Prediction") do
      nil ->
        Repo.insert!(%Biotope{
          name: "Weather Prediction",
          description:
            "Weather Prediction is a simulation of a weather forecasting system.
      The ecosystem is fed by weather data and the objective is to predict the weather.",
          image_url: "/images/weather_wars1.jpg",
          theme: "Weather",
          tags: "weather, forecast, prediction, climate, meteorology",
          difficulty: 4,
          objective: "Accurately predict weather patterns.",
          environment: "The a virtual weather system with dynamic weather changes.",
          challenges: "The challenges are to predict the weather accurately.",
          is_active?: false,
          biotope_type: "Swarm vs Environment",
          is_realistic?: true
        })

      _ ->
        :ok
    end
    case Repo.get_by(Biotope, name: "The Fitness Challenge") do
      nil ->
        Repo.insert!(%Biotope{
          name: "The Fitness Challenge",
          description:
            "The Fitness Challenge is a simulation of a population carrying wearable devices.
      The purpose of the ecosystem is to generate realistic streams of data with health metrics.",
          image_url: "/images/health_wars2.jpg",
          theme: "Life style",
          tags: "fitness, gym, health, exercise, competition",
          difficulty: 2,
          objective: "The objective is to have a healthy lifestyle.",
          environment: "The environment is a normal life.",
          challenges: "The challenges are to keep a healthy diet and exercise regularly.",
          is_active?: false,
          biotope_type: "Swarm vs Environment",
          is_realistic?: true
        })

      _ ->
        :ok
    end


    case Repo.get_by(Biotope, name: "The Great Migration") do
      nil ->
        Repo.insert!(%Biotope{
          name: "The Great Migration",
          description:
            "The Great Migration is a simulation of the great migration of the Serengeti.
        The ecosystem is fed by random data and the animals can migrate to find food and water.
        The animals can reproduce and die and the ecosystem is self-sustaining.",
          image_url: "/images/great_migration1.jpg",
          theme: "nature",
          tags: "nature, animals, migration, serengeti, africa",
          difficulty: 4,
          objective: "The objective is to survive the Serengeti.",
          environment: "The environment is the Serengeti.",
          challenges: "The challenges are to find food and water and avoid predators.",
          is_active?: false,
          biotope_type: "Swarm vs Environment",
          is_realistic?: false
        })

      _ ->
        :ok
    end

    case Repo.get_by(Biotope, name: "The Milk Factory") do
      nil ->
        Repo.insert!(%Biotope{
          name: "The Milk Factory",
          description: "The Milk Factory is a simulation of a dairy farm.
    The ecosystem is fed by weather data and the cows can be milked and reproduce.",
          image_url: "/images/dairy_wars1.jpg",
          theme: "agriculture",
          tags: "dairy, cows, milk, farm, agriculture",
          difficulty: 2,
          objective: "The objective is to run a successful dairy farm.",
          environment: "The environment is a dairy farm.",
          challenges: "The challenges are to keep the cows healthy and productive.",
          is_active?: false,
          biotope_type: "Swarm vs Environment",
          is_realistic?: false
        })

      _ ->
        :ok
    end
  end
end
