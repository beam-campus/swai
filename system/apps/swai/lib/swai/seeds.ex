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

  @aco_algorithm_id "c8487bb2-b69a-4c38-84c4-f9426606e73d"
  @bfo_algorithm_id "4eeef8e1-12e7-45fb-b141-656ffe594baf"
  @neat_algorithm_id "d5e90faa-98d6-4c79-8ba4-3db0fe41f9d5"
  @bso_algorithm_id "c0d60f91-3042-4949-b0ca-beaf72922d40"
  @pso_algorithm_id "d7eee4a9-214c-4eda-bdb6-6c5ad2e08bcb"
  @cuso_algorithm_id "1d9de2ce-6283-46b2-a473-87a30af77821"
  @caho_algorithm_id "46cf8a3d-df4f-4f9d-b6a6-6e5f1221d4a6"


  @planet_of_ants_id "b105f59e-42ce-4e85-833e-d123e36ce943"
  @milk_factory_id "db1563be-b269-4f6c-8ae9-daed364a8624"
  

  def run do
    seed_algorithms()
    seed_biotopes()
  end

  defp seed_algorithms() do
    case Repo.get_by(Schema.Algorithm, acronym: "ACO") do
      nil ->
        Repo.insert!(%Schema.Algorithm{
          id: @aco_algorithm_id,
          acronym: "ACO",
          name: "Ant Colony Optimization",
          description: "
            Ant Colony Optimization (ACO) is inspired by the foraging behavior of ants, particularly how they find the shortest path between their nest and a food source.
            Ants use pheromones to communicate and mark favorable paths, which helps the colony converge on efficient routes.
            ",
          image_url: "/images/planet_of_ants.jpg",
          definition: "
            # Mechanisms
            Pheromone Trail: Ants deposit pheromones on paths they travel. Other ants are more likely to follow paths with stronger pheromone concentrations.
            Exploration and Exploitation: Ants balance between exploring new paths and exploiting known good paths.
            Pheromone Evaporation: Over time, pheromones evaporate, which helps prevent convergence to suboptimal solutions and encourages exploration.
            Positive Feedback: Paths that lead to good solutions get reinforced by more pheromone deposits, guiding more ants to follow these paths.
            # Process
            Initialization: Initialize the pheromone levels on all possible paths.
            Ant Movement: Each ant moves from the nest to the food source, choosing paths probabilistically based on pheromone levels and path quality.
            Pheromone Update: After finding a food source, ants return to the nest, depositing pheromones on the paths they took.
            The amount of pheromone deposited is proportional to the quality of the path (e.g., shorter paths get more pheromones).
            Evaporation: Periodically reduce the pheromone levels on all paths to simulate evaporation.
            Iteration: Repeat the process for a number of iterations, allowing the colony to gradually converge on the shortest path.
            # Key Components:
            Pheromone Matrix: A matrix that keeps track of the pheromone levels on all possible paths.
            Probability Function: A function that determines the probability of an ant choosing a specific path based on pheromone levels and path quality.
            Pheromone Update Rule: A rule that specifies how much pheromone to deposit on paths based on the quality of the solution found.
            Evaporation Rate: A parameter that controls how quickly pheromones evaporate, balancing exploration and exploitation.
            ",
          tags: "optimization, ants, foraging, combinatorial optimization"
        })

      _ ->
        :ok
    end

    case Repo.get_by(Schema.Algorithm, acronym: "BFO") do
      nil ->
        Repo.insert!(%Schema.Algorithm{
          id: @bfo_algorithm_id,
          acronym: "BFO",
          name: "Bacterial Foraging Optimization",
          description:
            "Bacterial Foraging Optimization (BFO) is a metaheuristic optimization algorithm inspired by the foraging behavior of bacteria. BFO is used to solve optimization problems.",
          image_url: "/images/bfo.jpg",
          definition:
            "Bacterial Foraging Optimization (BFO) is a metaheuristic optimization algorithm inspired by the foraging behavior of bacteria. BFO is used to solve optimization problems.",
          tags: "optimization, bacteria, foraging"
        })

      _ ->
        :ok
    end

    case Repo.get_by(Schema.Algorithm, acronym: "NEAT") do
      nil ->
        Repo.insert!(%Schema.Algorithm{
          id: @neat_algorithm_id,
          acronym: "NEAT",
          name: "NeuroEvolution of Augmenting Topologies",
          description:
            "NeuroEvolution of Augmenting Topologies (NEAT) is a genetic algorithm used to evolve artificial neural networks. NEAT is used to solve optimization problems.",
          image_url: "/images/neat.jpg",
          definition:
            "NeuroEvolution of Augmenting Topologies (NEAT) is a genetic algorithm used to evolve artificial neural networks. NEAT is used to solve optimization problems.",
          tags: "optimization, neural networks, genetic algorithm"
        })

      _ ->
        :ok
    end

    case Repo.get_by(Schema.Algorithm, acronym: "BSO") do
      nil ->
        Repo.insert!(%Schema.Algorithm{
          id: @bso_algorithm_id,
          acronym: "BSO",
          name: "Bee Swarm Optimization",
          description:
            "Bee Swarm Optimization (BSO) is a metaheuristic optimization algorithm inspired by the foraging behavior of bees. BSO is used to solve optimization problems.",
          image_url: "/images/bso.jpg",
          definition:
            "Bee Swarm Optimization (BSO) is a metaheuristic optimization algorithm inspired by the foraging behavior of bees. BSO is used to solve optimization problems.",
          tags: "optimization, bees, foraging"
        })

      _ ->
        :ok
    end

    case Repo.get_by(Schema.Algorithm, acronym: "PSO") do
      nil ->
        Repo.insert!(%Schema.Algorithm{
          id: @pso_algorithm_id,
          acronym: "PSO",
          name: "Particle Swarm Optimization",
          description:
            "Particle Swarm Optimization (PSO) is a metaheuristic optimization algorithm inspired by the foraging behavior of birds. PSO is used to solve optimization problems.",
          image_url: "/images/pso.jpg",
          definition:
            "Particle Swarm Optimization (PSO) is a metaheuristic optimization algorithm inspired by the foraging behavior of birds. PSO is used to solve optimization problems.",
          tags: "optimization, birds, foraging"
        })

      _ ->
        :ok
    end

    case Repo.get_by(Schema.Algorithm, acronym: "CuSO") do
      nil ->
        Repo.insert!(%Schema.Algorithm{
          id: @cuso_algorithm_id,
          acronym: "CuSO",
          name: "Cuckoo Search Optimization",
          description:
            "Cuckoo Search Optimization (CHO) is a metaheuristic optimization algorithm inspired by the brood parasitism of some cuckoo species. CHO is used to solve optimization problems.",
          image_url: "/images/cho.jpg",
          definition:
            "Cuckoo Search Optimization (CHO) is a metaheuristic optimization algorithm inspired by the brood parasitism of some cuckoo species. CHO is used to solve optimization problems.",
          tags: "optimization, cuckoo, brood parasitism"
        })

      _ ->
        :ok
    end

    case Repo.get_by(Schema.Algorithm, acronym: "CaHO") do
      nil ->
        Repo.insert!(%Schema.Algorithm{
          id: @caho_algorithm_id,
          acronym: "CaHO",
          name: "Cattle Herding Optimization",
          description:
            "The algorithm is inspired by the behaviors of a herd of cows and bulls, including procreation, foraging for grass, and milk production.",
          image_url: "/images/gso.jpg",
          definition: "# Mechanism
                Foraging: Cows and bulls move around the pasture to find the best grass. This could be similar to the chemotaxis in BFO, where they move towards areas with richer grass.
                Procreation: Healthier and well-nourished cows and bulls reproduce, introducing new members to the herd. This mimics the reproduction step in BFO.
                Milk Production: The quality of grass eaten affects milk production, which can be seen as a measure of fitness.
                Swarming: Cows and bulls tend to move in groups (herding behavior), which is similar to the swarming behavior in BFO.
                Communication: Cows might have some basic form of communication to indicate good grazing spots, similar to the waggle dance in BSO.
                # Process
                Initialization: Start with an initial population of cows and bulls with random positions in the pasture.
                Foraging Behavior: Each member of the herd moves in the pasture to find the best grass. The movement could be influenced by local grass quality (akin to chemotaxis).
                Fitness Evaluation: Evaluate the fitness of each cow and bull based on the grass quality and amount of milk produced.
                Reproduction: Select the healthiest cows and bulls to reproduce, introducing new calves to the herd.
                Herding: Introduce herding behavior where groups of cows and bulls move together to explore new areas of the pasture.
                Elimination and Dispersal: Occasionally, some members of the herd might move to entirely new areas of the pasture to prevent local overgrazing and introduce diversity.
                # Key Components
                Fitness Function: A function that evaluates the fitness of each cow and bull based on the grass consumed and milk produced.
                Movement Strategy: A strategy that determines how cows and bulls move in the pasture, influenced by local grass quality.
                Reproduction Mechanism: A mechanism that selects the best cows and bulls for reproduction based on their fitness.
                Herding Behavior: A behavior that ensures cows and bulls move in groups to find the best grazing spots efficiently.
                Diversity Introduction: Occasionally move some members of the herd to new areas to explore different parts of the pasture.
                ",
          tags: "optimization, gravity, celestial bodies"
        })

      _ ->
        :ok
    end
  end

  ############################# BIOTOPES ########################################

  def seed_biotopes do
    case Repo.get_by(Biotope, name: "Planet of Ants") do
      nil ->
        Repo.insert!(%Biotope{
          id: @planet_of_ants_id,
          algorithm_id: @aco_algorithm_id,
          algorithm_acronym: "ACO",
          algorithm_name: "Ant Colony Optimization",
          name: "Planet of Ants",
          description:
            "Planet of Ants is a simulation of an ant colony. The ecosystem is fed by weather data and the ants can forage for food and reproduce. Each virtual colony generates a stream of foraging data that can be used for downstream applications.",
          image_url: "/images/planet_of_ants.jpg",
          theme: "nature",
          tags: "ants, colony, foraging, insects, nature",
          objectives: "The objective is to forage for food and keep the colony healthy.",
          environment: "The environment is an ant colony.",
          challenges: "The challenges are to keep the ants healthy and productive.",
          is_active?: true,
          is_realistic?: true
        })

      _ ->
        :ok
    end

    case Repo.get_by(Biotope, name: "The Milk Factory") do
      nil ->
        Repo.insert!(%Biotope{
          id: @milk_factory_id,
          algorithm_id: @caho_algorithm_id,
          algorithm_acronym: "CaHO",
          algorithm_name: "Cattle Herding Optimization",
          name: "The Milk Factory",
          description:
            "The Milk Factory is a simulation of a dairy farm. The ecosystem is fed by weather data and the cows can be milked and reproduce. Each virtual farm generates a stream of milking data that can be used for downstream applications.",
          image_url: "/images/dairy_wars1.jpg",
          theme: "agriculture",
          tags: "dairy, cows, milk, farm, agriculture",
          objectives:
            "The objective is to produce as much milk as possible, while keeping a healthy herd.",
          environment: "The environment is a dairy farm.",
          challenges: "The challenges are to keep the cows healthy and productive.",
          is_active?: false,
          is_realistic?: true
        })

      _ ->
        :ok
    end
  end

  # def seed_biotopes do

  #   case Repo.get_by(Biotope, name: "Traders of Macao") do
  #     nil ->

  #       case Repo.get_by(Biotope, name: "The Milk Factory") do
  #         nil ->
  #           Repo.insert!(%Biotope{
  #             name: "The Milk Factory",
  #             description: "The Milk Factory is a simulation of a dairy farm.
  #       The ecosystem is fed by weather data and the cows can be milked and reproduce.
  #       Each virtual farm generates a stream of milking data that can be used for downstream applications.",
  #             image_url: "/images/dairy_wars1.jpg",
  #             theme: "agriculture",
  #             tags: "dairy, cows, milk, farm, agriculture",
  #             difficulty: 2,
  #             objective: "The objective is to produce as much milk as possible, while keeping a healthy herd.",
  #             environment: "The environment is a dairy farm.",
  #             challenges: "The challenges are to keep the cows healthy and productive.",
  #             is_active?: false,
  #             biotope_type: "NEAT",
  #             is_realistic?: true,
  #             scape_id: "b1e27778-6fa6-4ca5-b642-72a531c6a00d"
  #           })

  #         _ ->
  #           :ok
  #       end

  #       Repo.insert!(%Biotope{
  #         name: "Traders of Macao",
  #         description:
  #           "Traders of Macao is an ecosystem that allows for swarms to trade resources.
  #       Individual worker bees are rewarded for making a profit and evolutionary selection happens by simple ranking.
  #       The ecosystem is fed by stock tickers and the bees can trade stocks, commodities, and cryptocurrencies.",
  #         image_url: "/images/trade_wars1.jpg",
  #         theme: "Finance",
  #         tags: "finance, stock market, trade, profit, cash",
  #         difficulty: 3,
  #         objective: "The objective is to make a profit.",
  #         environment: "The environment is a stock market.",
  #         challenges: "The challenges are to predict the market and make the right trades.",
  #         is_active?: false,
  #         biotope_type: "NEAT",
  #         is_realistic?: true,
  #         scape_id: "dea846a5-a559-4494-8f95-5f8e4e14ea20"
  #       })

  #     _ ->
  #       :ok
  #   end

  #   case Repo.get_by(Biotope, name: "Performance Art Competition") do
  #     nil ->
  #       Repo.insert!(%Biotope{
  #         name: "Performance Art Competition",
  #         description:
  #           "Performance Art Competition is a simulation of a performance art competition.
  #     The ecosystem is fed by performance data and the objective is to win the competition.",
  #         image_url: "/images/performance_wars1.jpg",
  #         theme: "Art",
  #         tags: "performance, art, competition, music, dance",
  #         difficulty: 3,
  #         objective: " Create and perform the most impressive synchronized routines.",
  #         environment: "A performance stage with various props and settings.",
  #         challenges: "Designing intricate routines, coordinating swarm movements, and timing performances perfectly.
  #         Audience reactions and judges' scores determine the winner.",
  #         is_active?: false,
  #         biotope_type: "Ant Colony Optimization",
  #         is_realistic?: false,
  #         scape_id: "f4153cee-b972-4ba7-839a-b15e25d7bc02"
  #       })

  #     _ ->
  #       :ok
  #   end

  #   case Repo.get_by(Biotope, name: "Pollution Cleanup") do
  #     nil ->
  #       Repo.insert!(%Biotope{
  #         name: "Pollution Cleanup",
  #         description:
  #           "Pollution Cleanup is a simulation of a pollution cleanup system.
  #     The ecosystem is fed by pollution data and the objective is to clean up the pollution.",
  #         image_url: "/images/pollution_wars1.jpg",
  #         theme: "Environment",
  #         tags: "pollution, cleanup, environment, climate, ecology",
  #         difficulty: 3,
  #         objective: "Clean up pollutants from a contaminated environment.",
  #         environment: "A polluted landscape with various types of pollutants.",
  #         challenges: "The challenges are to clean up the pollution.",
  #         is_active?: false,
  #         biotope_type: "Bacterial Foraging Optimization",
  #         is_realistic?: false,
  #         scape_id: "85ca41c1-0876-49ec-b7ed-4d7ec34dd3e4"
  #       })

  #     _ ->
  #       :ok
  #   end

  #   case Repo.get_by(Biotope, name: "Delivery Rush") do
  #     nil ->
  #       Repo.insert!(%Biotope{
  #         name: "Delivery Rush",
  #         description:
  #           "This ecosystem is inspired by the infamous 'Traveling Salesman Problem'.
  #           The objective is to deliver packages to customers in the most efficient way possible.
  #           The environment is a city with various locations and the challenges are to optimize the delivery routes.
  #           The ecosystem is fed by real time traffic data and the drones must deliver packages as quickly as possible.",
  #         image_url: "/images/delivery_rush.jpg",
  #         theme: "Logistics",
  #         tags: "delivery, routes, commerce",
  #         difficulty: 4,
  #         objective: "Deliver packages to customers in the most efficient way possible.",
  #         environment: "A city with various locations and varying traffic.",
  #         challenges: "A complex and varying city environment with traffic congestion and time constraints.",
  #         is_active?: true,
  #         biotope_type: "Ant Colony Optimization",
  #         is_realistic?: true,
  #         scape_id: "5693504a-89d6-4af3-bb70-2c2914913dc9"
  #       })

  #     _ ->
  #       :ok
  #   end

  #   case Repo.get_by(Biotope, name: "Weather Prediction") do
  #     nil ->
  #       Repo.insert!(%Biotope{
  #         name: "Weather Prediction",
  #         description:
  #           "Weather Prediction is a simulation of a weather forecasting system.
  #     The ecosystem is fed by weather data and the objective is to predict the weather.",
  #         image_url: "/images/weather_wars1.jpg",
  #         theme: "Weather",
  #         tags: "weather, forecast, prediction, climate, meteorology",
  #         difficulty: 4,
  #         objective: "Accurately predict weather patterns.",
  #         environment: "The a virtual weather system with dynamic weather changes.",
  #         challenges: "The challenges are to predict the weather accurately.",
  #         is_active?: false,
  #         biotope_type: "NEAT",
  #         is_realistic?: true,
  #         scape_id: "756803bc-5e35-411a-8eac-9b7d4d499b38"
  #       })

  #     _ ->
  #       :ok
  #   end

  #   case Repo.get_by(Biotope, name: "The Fitness Challenge") do
  #     nil ->
  #       Repo.insert!(%Biotope{
  #         name: "The Fitness Challenge",
  #         description:
  #           "The Fitness Challenge is a simulation of a population carrying wearable devices.
  #     The purpose of the ecosystem is to generate realistic streams of data with health metrics.",
  #         image_url: "/images/health_wars2.jpg",
  #         theme: "Life style",
  #         tags: "fitness, gym, health, exercise, competition",
  #         difficulty: 2,
  #         objective: "The objective is to have a healthy lifestyle.",
  #         environment: "The environment is a normal life.",
  #         challenges: "The challenges are to keep a healthy diet and exercise regularly.",
  #         is_active?: false,
  #         biotope_type: "NEAT",
  #         is_realistic?: true,
  #         scape_id: "9fe76472-833f-4e2e-a884-0501454ea721"
  #       })

  #     _ ->
  #       :ok
  #   end

  #   case Repo.get_by(Biotope, name: "The Great Migration") do
  #     nil ->
  #       Repo.insert!(%Biotope{
  #         name: "The Great Migration",
  #         description:
  #           "The Great Migration is a simulation of the great migration of the Serengeti.
  #       The ecosystem is fed by random data and the animals can migrate to find food and water.
  #       The animals can reproduce and die and the ecosystem is self-sustaining.",
  #         image_url: "/images/great_migration1.jpg",
  #         theme: "nature",
  #         tags: "nature, animals, migration, serengeti, africa",
  #         difficulty: 4,
  #         objective: "The objective is to survive the Serengeti.",
  #         environment: "The environment is the Serengeti.",
  #         challenges: "The challenges are to find food and water and avoid predators.",
  #         is_active?: false,
  #         biotope_type: "NEAT",
  #         is_realistic?: false,
  #         scape_id: "8f809a29-994c-4279-9fe8-8952042c2f81"
  #       })

  #     _ ->
  #       :ok
  #   end

  # end
end
