defmodule Pinchflat.Pages.JobQueueLive do
  @moduledoc """
  LiveView component for displaying the Oban job queue status.

  Shows jobs grouped by state with the ability to see details and cancel jobs.
  """
  use PinchflatWeb, :live_view
  use Pinchflat.Tasks.TasksQuery

  import Ecto.Query, warn: false

  alias Pinchflat.Repo
  alias PinchflatWeb.CustomComponents.TextComponents

  @refresh_interval_ms 5_000

  def render(assigns) do
    ~H"""
    <div class="space-y-4">
      <div class="flex items-center justify-between mb-4">
        <div class="flex items-center space-x-2">
          <.icon_button icon_name="hero-arrow-path" class="h-8 w-8" phx-click="refresh" tooltip="Refresh" />
          <span class="text-sm text-gray-400">
            Auto-refreshes every {div(@refresh_interval, 1000)}s
          </span>
        </div>
      </div>

      <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
        <.stat_card label="Executing" count={@stats.executing} color="green" />
        <.stat_card label="Available" count={@stats.available} color="blue" />
        <.stat_card label="Scheduled" count={@stats.scheduled} color="yellow" />
        <.stat_card label="Retryable" count={@stats.retryable} color="orange" />
      </div>

      <div class="space-y-6">
        <.job_section
          :if={@executing_jobs != []}
          title="Executing Jobs"
          jobs={@executing_jobs}
          state="executing"
          show_cancel={true}
        />

        <.job_section
          :if={@available_jobs != []}
          title="Available Jobs (waiting to run)"
          jobs={@available_jobs}
          state="available"
          show_cancel={true}
        />

        <.job_section
          :if={@scheduled_jobs != []}
          title="Scheduled Jobs"
          jobs={@scheduled_jobs}
          state="scheduled"
          show_cancel={true}
        />

        <.job_section
          :if={@retryable_jobs != []}
          title="Retryable Jobs (will retry)"
          jobs={@retryable_jobs}
          state="retryable"
          show_cancel={true}
        />

        <.job_section
          :if={@failed_jobs != []}
          title="Recently Failed Jobs"
          jobs={@failed_jobs}
          state="discarded"
          show_cancel={false}
        />

        <div
          :if={
            @executing_jobs == [] && @available_jobs == [] && @scheduled_jobs == [] && @retryable_jobs == [] &&
              @failed_jobs == []
          }
          class="text-center py-8 text-gray-400"
        >
          <p>No active or pending jobs</p>
        </div>
      </div>
    </div>
    """
  end

  attr :label, :string, required: true
  attr :count, :integer, required: true
  attr :color, :string, required: true

  defp stat_card(assigns) do
    color_classes =
      case assigns.color do
        "green" -> "border-green-500 text-green-400"
        "blue" -> "border-blue-500 text-blue-400"
        "yellow" -> "border-yellow-500 text-yellow-400"
        "orange" -> "border-orange-500 text-orange-400"
        _ -> "border-gray-500 text-gray-400"
      end

    assigns = assign(assigns, :color_classes, color_classes)

    ~H"""
    <div class={"rounded-lg border-l-4 bg-boxdark p-4 #{@color_classes}"}>
      <div class="text-2xl font-bold">{@count}</div>
      <div class="text-sm text-gray-400">{@label}</div>
    </div>
    """
  end

  attr :title, :string, required: true
  attr :jobs, :list, required: true
  attr :state, :string, required: true
  attr :show_cancel, :boolean, default: false

  defp job_section(assigns) do
    ~H"""
    <div class="rounded-lg bg-boxdark p-4">
      <h3 class="text-lg font-semibold mb-3">{@title}</h3>
      <div class="max-w-full overflow-x-auto">
        <.table rows={@jobs} table_class="text-white text-sm">
          <:col :let={job} label="Worker">
            {worker_to_short_name(job.worker)}
          </:col>
          <:col :let={job} label="Subject" class="truncate max-w-xs">
            {job_to_subject(job)}
          </:col>
          <:col :let={job} label="Attempt">
            {job.attempt}/{job.max_attempts}
          </:col>
          <:col :let={job} label="Scheduled">
            {format_datetime(job.scheduled_at)}
          </:col>
          <:col :let={job} :if={@state == "discarded"} label="Error" class="truncate max-w-xs">
            <.tooltip :if={job.errors != []} tooltip={format_errors(job.errors)} position="left" tooltip_class="w-96">
              <span class="text-red-400 cursor-help">{truncate_error(job.errors)}</span>
            </.tooltip>
          </:col>
          <:col :let={job} :if={@show_cancel} label="">
            <button
              phx-click="cancel_job"
              phx-value-job-id={job.id}
              class="text-red-400 hover:text-red-300 text-xs"
              data-confirm="Are you sure you want to cancel this job?"
            >
              Cancel
            </button>
          </:col>
        </.table>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    if connected?(socket) do
      PinchflatWeb.Endpoint.subscribe("job:state")
      Process.send_after(self(), :tick, @refresh_interval_ms)
    end

    {:ok, assign(socket, refresh_interval: @refresh_interval_ms) |> fetch_job_data()}
  end

  def handle_event("refresh", _params, socket) do
    {:noreply, fetch_job_data(socket)}
  end

  def handle_event("cancel_job", %{"job-id" => job_id}, socket) do
    job_id = String.to_integer(job_id)
    Oban.cancel_job(job_id)

    {:noreply, fetch_job_data(socket)}
  end

  def handle_info(%{topic: "job:state", event: "change"}, socket) do
    {:noreply, fetch_job_data(socket)}
  end

  def handle_info(:tick, socket) do
    Process.send_after(self(), :tick, @refresh_interval_ms)
    {:noreply, fetch_job_data(socket)}
  end

  defp fetch_job_data(socket) do
    stats = fetch_job_stats()

    assign(socket,
      stats: stats,
      executing_jobs: fetch_jobs_by_state("executing", 10),
      available_jobs: fetch_jobs_by_state("available", 10),
      scheduled_jobs: fetch_jobs_by_state("scheduled", 10),
      retryable_jobs: fetch_jobs_by_state("retryable", 10),
      failed_jobs: fetch_failed_jobs(10)
    )
  end

  defp fetch_job_stats do
    query =
      from(j in Oban.Job,
        where: j.state in ["executing", "available", "scheduled", "retryable"],
        group_by: j.state,
        select: {j.state, count(j.id)}
      )

    stats_map = query |> Repo.all() |> Enum.into(%{})

    %{
      executing: Map.get(stats_map, "executing", 0),
      available: Map.get(stats_map, "available", 0),
      scheduled: Map.get(stats_map, "scheduled", 0),
      retryable: Map.get(stats_map, "retryable", 0)
    }
  end

  defp fetch_jobs_by_state(state, limit) do
    order_by_clause =
      case state do
        "executing" -> [desc: :attempted_at]
        "scheduled" -> [asc: :scheduled_at]
        _ -> [asc: :id]
      end

    from(j in Oban.Job,
      where: j.state == ^state,
      order_by: ^order_by_clause,
      limit: ^limit
    )
    |> Repo.all()
  end

  defp fetch_failed_jobs(limit) do
    # Show recently failed jobs from the last 24 hours
    cutoff = DateTime.utc_now() |> DateTime.add(-24, :hour)

    from(j in Oban.Job,
      where: j.state in ["discarded", "cancelled"],
      where: j.inserted_at > ^cutoff,
      order_by: [desc: :inserted_at],
      limit: ^limit
    )
    |> Repo.all()
  end

  defp worker_to_short_name(worker) do
    worker
    |> String.split(".")
    |> Enum.at(-1)
    |> String.replace("Worker", "")
    |> String.replace(~r/([a-z])([A-Z])/, "\\1 \\2")
  end

  defp job_to_subject(job) do
    case job.args do
      %{"id" => id} -> "ID: #{id}"
      _ -> "N/A"
    end
  end

  defp format_datetime(nil), do: ""

  defp format_datetime(datetime) do
    TextComponents.datetime_in_zone(%{datetime: datetime, format: "%Y-%m-%d %H:%M:%S"})
  end

  defp format_errors([]), do: "No errors"

  defp format_errors(errors) when is_list(errors) do
    errors
    |> Enum.take(3)
    |> Enum.map_join("\n\n", fn error ->
      case error do
        %{"error" => msg, "at" => at} -> "#{at}: #{msg}"
        %{"error" => msg} -> msg
        msg when is_binary(msg) -> msg
        other -> inspect(other)
      end
    end)
  end

  defp truncate_error([]), do: "No error"

  defp truncate_error([error | _]) do
    msg =
      case error do
        %{"error" => msg} -> msg
        msg when is_binary(msg) -> msg
        other -> inspect(other)
      end

    if String.length(msg) > 50 do
      String.slice(msg, 0, 50) <> "..."
    else
      msg
    end
  end
end
