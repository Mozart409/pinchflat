defmodule PinchflatWeb.Api.TaskControllerTest do
  use PinchflatWeb.ConnCase

  import Pinchflat.TasksFixtures
  import Pinchflat.SourcesFixtures
  import Pinchflat.MediaFixtures

  alias Pinchflat.Tasks

  describe "GET /api/tasks" do
    test "returns list of tasks", %{conn: conn} do
      task1 = task_fixture()
      task2 = task_fixture()

      conn = get(conn, "/api/tasks")
      response = json_response(conn, 200)

      ids = Enum.map(response["data"], & &1["id"])
      assert task1.id in ids
      assert task2.id in ids
    end

    test "filters by source_id", %{conn: conn} do
      source = source_fixture()
      task = task_fixture(%{source_id: source.id})
      _other_task = task_fixture()

      conn = get(conn, "/api/tasks?source_id=#{source.id}")
      response = json_response(conn, 200)

      ids = Enum.map(response["data"], & &1["id"])
      assert ids == [task.id]
    end

    test "filters by media_item_id", %{conn: conn} do
      media_item = media_item_fixture()
      task = task_fixture(%{media_item_id: media_item.id, source_id: nil})
      _other_task = task_fixture()

      conn = get(conn, "/api/tasks?media_item_id=#{media_item.id}")
      response = json_response(conn, 200)

      ids = Enum.map(response["data"], & &1["id"])
      assert ids == [task.id]
    end

    test "returns empty list when no tasks exist", %{conn: conn} do
      conn = get(conn, "/api/tasks")
      response = json_response(conn, 200)

      assert response["data"] == []
    end
  end

  describe "GET /api/tasks/:id" do
    test "returns task details", %{conn: conn} do
      task = task_fixture()

      conn = get(conn, "/api/tasks/#{task.id}")
      response = json_response(conn, 200)

      assert response["id"] == task.id
      assert response["job_id"] == task.job_id
      assert Map.has_key?(response, "worker")
      assert Map.has_key?(response, "state")
    end

    test "returns 404 when task does not exist", %{conn: conn} do
      assert_error_sent 404, fn ->
        get(conn, "/api/tasks/99999")
      end
    end
  end

  describe "DELETE /api/tasks/:id" do
    test "cancels and deletes task", %{conn: conn} do
      task = task_fixture()

      conn = delete(conn, "/api/tasks/#{task.id}")
      response = json_response(conn, 200)

      assert response["message"] == "Task cancelled successfully"
      refute Tasks.list_tasks() |> Enum.any?(&(&1.id == task.id))
    end

    test "returns 404 when task does not exist", %{conn: conn} do
      assert_error_sent 404, fn ->
        delete(conn, "/api/tasks/99999")
      end
    end
  end
end
