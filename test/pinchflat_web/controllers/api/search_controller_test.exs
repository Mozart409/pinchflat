defmodule PinchflatWeb.Api.SearchControllerTest do
  use PinchflatWeb.ConnCase

  import Pinchflat.MediaFixtures

  describe "GET /api/search" do
    test "returns search results", %{conn: conn} do
      item = media_item_fixture(%{title: "My Unique Video Title"})

      conn = get(conn, "/api/search?q=Unique")
      response = json_response(conn, 200)

      assert response["query"] == "Unique"
      ids = Enum.map(response["data"], & &1["id"])
      assert item.id in ids
    end

    test "returns empty results for no matches", %{conn: conn} do
      _item = media_item_fixture(%{title: "Some Video"})

      conn = get(conn, "/api/search?q=NoMatch")
      response = json_response(conn, 200)

      assert response["query"] == "NoMatch"
      assert response["data"] == []
    end

    test "returns empty results for empty query", %{conn: conn} do
      _item = media_item_fixture()

      conn = get(conn, "/api/search?q=")
      response = json_response(conn, 200)

      assert response["query"] == ""
      assert response["data"] == []
    end

    test "respects limit param", %{conn: conn} do
      for i <- 1..10 do
        media_item_fixture(%{title: "Search Test #{i}"})
      end

      conn = get(conn, "/api/search?q=Search&limit=5")
      response = json_response(conn, 200)

      assert length(response["data"]) == 5
    end

    test "handles missing query param", %{conn: conn} do
      conn = get(conn, "/api/search")
      response = json_response(conn, 200)

      assert response["query"] == ""
      assert response["data"] == []
    end
  end
end
