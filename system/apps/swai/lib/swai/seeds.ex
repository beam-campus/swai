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


        case Repo.get_by(Biotope, name: "The Milk Factory") do
          nil ->
            Repo.insert!(%Biotope{
              name: "The Milk Factory",
              description: "The Milk Factory is a simulation of a dairy farm.
        The ecosystem is fed by weather data and the cows can be milked and reproduce.
        Each virtual farm generates a stream of milking data that can be used for downstream applications.",
              image_url: "/images/dairy_wars1.jpg",
              theme: "agriculture",
              tags: "dairy, cows, milk, farm, agriculture",
              difficulty: 2,
              objective: "The objective is to produce as much milk as possible, while keeping a healthy herd.",
              environment: "The environment is a dairy farm.",
              challenges: "The challenges are to keep the cows healthy and productive.",
              is_active?: false,
              biotope_type: "NEAT",
              is_realistic?: true,
              scape_id: "b1e27778-6fa6-4ca5-b642-72a531c6a00d"
            })

          _ ->
            :ok
        end



        Repo.insert!(%Biotope{
          name: "Traders of Macao",
          description:
            "Traders of Macao is an ecosystem that allows for swarms to trade resources.
        Individual worker bees are rewarded for making a profit and evolutionary selection happens by simple ranking.
        The ecosystem is fed by stock tickers and the bees can trade stocks, commodities, and cryptocurrencies.",
          image_url: "/images/trade_wars1.jpg",
          theme: "Finance",
          tags: "finance, stock market, trade, profit, cash",
          difficulty: 3,
          objective: "The objective is to make a profit.",
          environment: "The environment is a stock market.",
          challenges: "The challenges are to predict the market and make the right trades.",
          is_active?: false,
          biotope_type: "NEAT",
          is_realistic?: true,
          scape_id: "dea846a5-a559-4494-8f95-5f8e4e14ea20"
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
          biotope_type: "Ant Colony Optimization",
          is_realistic?: false,
          scape_id: "f4153cee-b972-4ba7-839a-b15e25d7bc02"
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
          biotope_type: "Bacterial Foraging Optimization",
          is_realistic?: false,
          scape_id: "85ca41c1-0876-49ec-b7ed-4d7ec34dd3e4"
        })

      _ ->
        :ok
    end


    case Repo.get_by(Biotope, name: "Delivery Rush") do
      nil ->
        Repo.insert!(%Biotope{
          name: "Delivery Rush",
          description:
            "This ecosystem is inspired by the infamous 'Traveling Salesman Problem'.
            The objective is to deliver packages to customers in the most efficient way possible.
            The environment is a city with various locations and the challenges are to optimize the delivery routes.
            The ecosystem is fed by real time traffic data and the drones must deliver packages as quickly as possible.",
          image_url: "/images/delivery_rush.jpg",
          theme: "Logistics",
          tags: "delivery, routes, commerce",
          difficulty: 4,
          objective: "Deliver packages to customers in the most efficient way possible.",
          environment: "A city with various locations and varying traffic.",
          challenges: "A complex and varying city environment with traffic congestion and time constraints.",
          is_active?: true,
          biotope_type: "Ant Colony Optimization",
          is_realistic?: true,
          scape_id: "5693504a-89d6-4af3-bb70-2c2914913dc9"
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
          biotope_type: "NEAT",
          is_realistic?: true,
          scape_id: "756803bc-5e35-411a-8eac-9b7d4d499b38"
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
          biotope_type: "NEAT",
          is_realistic?: true,
          scape_id: "9fe76472-833f-4e2e-a884-0501454ea721"
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
          biotope_type: "NEAT",
          is_realistic?: false,
          scape_id: "8f809a29-994c-4279-9fe8-8952042c2f81"
        })

      _ ->
        :ok
    end


  end
end
