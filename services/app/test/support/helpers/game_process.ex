defmodule Helpers.GameProcess do
  @moduledoc """
  Test helpers for GameProcess context
  """

  import CodebattleWeb.Factory

  alias Codebattle.GameProcess.{GlobalSupervisor, Fsm, ActiveGames}

  def setup_game(state, data) do
    game = insert(:game)
    data = Map.put(data, :game_id, game.id)
    data = Map.put(data, :level, game.task.level)
    data = Map.put(data, :task, game.task)
    data = Map.put(data, :starts_at, TimeHelper.utc_now())
    fsm = Fsm.set_data(state, data)
    ActiveGames.setup_game(fsm)
    GlobalSupervisor.start_game(game.id, fsm)
    game
  end

  def start_game_recorder(game_id, task_id, user_id) do
    Codebattle.Bot.RecorderServer.start(game_id, task_id, user_id)
  end

  def game_id_from_conn(conn) do
    location =
      conn.resp_headers
      |> Enum.find(&match?({"location", _}, &1))
      |> elem(1)

    ~r/\d+/
    |> Regex.run(location)
    |> List.first()
    |> String.to_integer()
  end
end
