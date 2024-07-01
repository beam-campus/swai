defmodule SwaiWeb.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  require Code
  @app :swai_web

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end

    path_to_seeds = Application.app_dir(@app, "priv/repo/seeds.exs")

    Code.eval_file(path_to_seeds)

  end
  

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
