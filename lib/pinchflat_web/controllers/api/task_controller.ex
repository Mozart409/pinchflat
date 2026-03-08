defmodule PinchflatWeb.Api.TaskController do
  use PinchflatWeb, :controller

  import Ecto.Query, warn: false

  alias Pinchflat.Repo
  alias Pinchflat.Tasks
  alias Pinchflat.Tasks.Task
  alias Pinchflat.Sources.Source
  alias Pinchflat.Media.MediaItem

  def index(conn, params) do
    tasks =
      cond do
        source_id = params["source_id"] ->
          source = Repo.get!(Source, source_id)
          worker = params["worker"]
          states = parse_states(params["state"])
          Tasks.list_tasks_for(source, worker, states)

        media_item_id = params["media_item_id"] ->
          media_item = Repo.get!(MediaItem, media_item_id)
          worker = params["worker"]
          states = parse_states(params["state"])
          Tasks.list_tasks_for(media_item, worker, states)

        true ->
          query = from(t in Task)

          query =
            if worker = params["worker"] do
              worker_finder = "%.#{worker}"

              from(t in query,
                join: j in assoc(t, :job),
                where: fragment("? LIKE ?", j.worker, ^worker_finder)
              )
            else
              query
            end

          query =
            if state = params["state"] do
              from(t in query,
                join: j in assoc(t, :job),
                where: j.state == ^to_string(state)
              )
            else
              query
            end

          Repo.all(query)
      end

    tasks_with_jobs = tasks |> Repo.preload(:job)

    serialized_tasks =
      Enum.map(tasks_with_jobs, fn task ->
        %{
          id: task.id,
          job_id: task.job_id,
          source_id: task.source_id,
          media_item_id: task.media_item_id,
          worker: task.job.worker,
          state: task.job.state,
          args: task.job.args,
          errors: task.job.errors,
          attempt: task.job.attempt,
          max_attempts: task.job.max_attempts,
          inserted_at: task.inserted_at,
          scheduled_at: task.job.scheduled_at,
          attempted_at: task.job.attempted_at,
          completed_at: task.job.completed_at
        }
      end)

    conn
    |> put_status(:ok)
    |> json(%{data: serialized_tasks})
  end

  def show(conn, %{"id" => id}) do
    task = Tasks.get_task!(id) |> Repo.preload(:job)

    serialized_task = %{
      id: task.id,
      job_id: task.job_id,
      source_id: task.source_id,
      media_item_id: task.media_item_id,
      worker: task.job.worker,
      state: task.job.state,
      args: task.job.args,
      errors: task.job.errors,
      attempt: task.job.attempt,
      max_attempts: task.job.max_attempts,
      inserted_at: task.inserted_at,
      scheduled_at: task.job.scheduled_at,
      attempted_at: task.job.attempted_at,
      completed_at: task.job.completed_at
    }

    conn
    |> put_status(:ok)
    |> json(serialized_task)
  end

  def delete(conn, %{"id" => id}) do
    task = Tasks.get_task!(id)
    {:ok, _task} = Tasks.delete_task(task)

    conn
    |> put_status(:ok)
    |> json(%{message: "Task cancelled successfully"})
  end

  defp parse_states(nil), do: Oban.Job.states()

  defp parse_states(state) when is_binary(state) do
    [String.to_existing_atom(state)]
  end

  defp parse_states(states) when is_list(states) do
    Enum.map(states, &String.to_existing_atom/1)
  end
end
