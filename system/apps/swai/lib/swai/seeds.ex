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
    case Repo.get_by(Biotope, name: "The Fitness Challenge") do
      nil ->
        Repo.insert!(%Biotope{
          name: "The Fitness Challenge",
          description:
            "The Fitness Challenge is a simulation of a population carrying wearable devices.
      The purpose of the ecosystem is to generate realistic streams of data with health metrics.",
          image_url: "/images/health_wars2.jpg",
          theme: "Life style",
          tags: "fitness, gym, health, exercise, competition"
        })

      _ ->
        :ok
    end

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
          tags: "finance, stock market, trade, profit, cash"
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
        The ecosystem is fed by weather data and the animals can migrate to find food and water.
        The animals can reproduce and die and the ecosystem is self-sustaining.",
          image_url: "/images/great_migration1.jpg",
          theme: "nature",
          tags: "nature, animals, migration, serengeti, africa"
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
          tags: "dairy, cows, milk, farm, agriculture"
        })

      _ ->
        :ok
    end
  end
end
