defmodule PinchflatWeb.Api.StatsController do
  use PinchflatWeb, :controller
  use Pinchflat.Media.MediaQuery

  alias Pinchflat.Repo
  alias Pinchflat.Sources.Source
  alias Pinchflat.Profiles.MediaProfile

  def index(conn, _params) do
    downloaded_media_items = where(MediaQuery.new(), ^MediaQuery.downloaded())

    stats = %{
      media_profile_count: Repo.aggregate(MediaProfile, :count, :id),
      source_count: Repo.aggregate(Source, :count, :id),
      media_item_count: Repo.aggregate(downloaded_media_items, :count, :id),
      total_download_size_bytes: Repo.aggregate(downloaded_media_items, :sum, :media_size_bytes) || 0
    }

    conn
    |> put_status(:ok)
    |> json(stats)
  end
end
