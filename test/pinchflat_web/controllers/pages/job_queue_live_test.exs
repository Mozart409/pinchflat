defmodule PinchflatWeb.Pages.JobQueueLiveTest do
  use PinchflatWeb.ConnCase

  import Ecto.Query, warn: false
  import Phoenix.LiveViewTest
  import Pinchflat.SourcesFixtures

  alias Pinchflat.Pages.JobQueueLive
  alias Pinchflat.FastIndexing.FastIndexingWorker

  describe "initial rendering" do
    test "shows stats cards", %{conn: conn} do
      {:ok, _view, html} = live_isolated(conn, JobQueueLive, session: %{})

      assert html =~ "Executing"
      assert html =~ "Available"
      assert html =~ "Scheduled"
      assert html =~ "Retryable"
    end

    test "shows no active jobs message when queue is empty", %{conn: conn} do
      {:ok, _view, html} = live_isolated(conn, JobQueueLive, session: %{})

      assert html =~ "No active or pending jobs"
    end

    test "shows available jobs when present", %{conn: conn} do
      source = source_fixture()
      {:ok, _task} = FastIndexingWorker.kickoff_with_task(source)

      {:ok, _view, html} = live_isolated(conn, JobQueueLive, session: %{})

      assert html =~ "Available Jobs"
      assert html =~ "Fast Indexing"
    end

    test "shows executing jobs when present", %{conn: conn} do
      source = source_fixture()
      {:ok, task} = FastIndexingWorker.kickoff_with_task(source)

      Oban.Job
      |> where([j], j.id == ^task.job_id)
      |> Repo.update_all(set: [state: "executing"])

      {:ok, _view, html} = live_isolated(conn, JobQueueLive, session: %{})

      assert html =~ "Executing Jobs"
    end
  end

  describe "job actions" do
    test "can cancel a job", %{conn: conn} do
      source = source_fixture()
      {:ok, task} = FastIndexingWorker.kickoff_with_task(source)

      {:ok, view, _html} = live_isolated(conn, JobQueueLive, session: %{})

      view
      |> element("button[phx-click='cancel_job'][phx-value-job-id='#{task.job_id}']")
      |> render_click()

      # Job should be cancelled
      job = Repo.get!(Oban.Job, task.job_id)
      assert job.state == "cancelled"
    end

    test "refresh button updates the view", %{conn: conn} do
      {:ok, view, _html} = live_isolated(conn, JobQueueLive, session: %{})

      # Should not error
      html = view |> element("button[phx-click='refresh']") |> render_click()

      assert html =~ "Executing"
    end
  end

  describe "pubsub updates" do
    test "updates view when job:state changes", %{conn: conn} do
      {:ok, view, _html} = live_isolated(conn, JobQueueLive, session: %{})

      # Create a job after the initial render
      source = source_fixture()
      {:ok, _task} = FastIndexingWorker.kickoff_with_task(source)

      # Trigger a refresh
      PinchflatWeb.Endpoint.broadcast("job:state", "change", nil)

      # Wait a moment for the view to process
      :timer.sleep(50)

      # Re-render should show the new job
      html = render(view)
      assert html =~ "Fast Indexing"
    end
  end
end
