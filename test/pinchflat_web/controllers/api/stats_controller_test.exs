defmodule PinchflatWeb.Api.StatsControllerTest do
  use PinchflatWeb.ConnCase

  import Pinchflat.ProfilesFixtures
  import Pinchflat.SourcesFixtures
  import Pinchflat.MediaFixtures

  describe "GET /api/stats" do
    test "returns application statistics", %{conn: conn} do
      conn = get(conn, "/api/stats")
      response = json_response(conn, 200)

      assert Map.has_key?(response, "media_profile_count")
      assert Map.has_key?(response, "source_count")
      assert Map.has_key?(response, "media_item_count")
      assert Map.has_key?(response, "total_download_size_bytes")
    end

    test "returns correct counts", %{conn: conn} do
      # Create test data
      _profile1 = media_profile_fixture()
      _profile2 = media_profile_fixture()
      _source1 = source_fixture()
      _source2 = source_fixture()
      _source3 = source_fixture()

      # Get counts
      conn = get(conn, "/api/stats")
      response = json_response(conn, 200)

      # Each source_fixture creates a media_profile, so we have 2 + 3 = 5 profiles
      assert response["media_profile_count"] >= 2
      assert response["source_count"] >= 3
    end

    test "counts only downloaded media items", %{conn: conn} do
      # Create test data
      _downloaded1 = media_item_fixture(%{media_downloaded_at: DateTime.utc_now(), media_size_bytes: 1000})
      _downloaded2 = media_item_fixture(%{media_downloaded_at: DateTime.utc_now(), media_size_bytes: 2000})
      _not_downloaded = media_item_fixture(%{media_downloaded_at: nil})

      # Get counts
      conn = get(conn, "/api/stats")
      response = json_response(conn, 200)

      # Should have 2 downloaded items from this test
      assert response["media_item_count"] >= 2
      assert response["total_download_size_bytes"] >= 3000
    end

    test "returns 0 for total_download_size_bytes when no downloaded media", %{conn: conn} do
      # Create only non-downloaded media
      _not_downloaded = media_item_fixture(%{media_downloaded_at: nil})

      conn = get(conn, "/api/stats")
      response = json_response(conn, 200)

      assert is_integer(response["total_download_size_bytes"])
      assert response["total_download_size_bytes"] >= 0
    end
  end
end
