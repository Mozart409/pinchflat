defmodule PinchflatWeb.Api.SourceActionsController do
  use PinchflatWeb, :controller

  alias Pinchflat.Sources
  alias Pinchflat.Downloading.DownloadingHelpers
  alias Pinchflat.SlowIndexing.SlowIndexingHelpers
  alias Pinchflat.Metadata.SourceMetadataStorageWorker
  alias Pinchflat.Media.FileSyncingWorker

  def download_pending(conn, %{"id" => id}) do
    source = Sources.get_source!(id)
    DownloadingHelpers.enqueue_pending_download_tasks(source)

    conn
    |> put_status(:ok)
    |> json(%{message: "Download jobs created for pending media items"})
  end

  def redownload(conn, %{"id" => id}) do
    source = Sources.get_source!(id)
    DownloadingHelpers.kickoff_redownload_for_existing_media(source)

    conn
    |> put_status(:ok)
    |> json(%{message: "Re-download jobs created for existing media items"})
  end

  def index(conn, %{"id" => id}) do
    source = Sources.get_source!(id)
    SlowIndexingHelpers.kickoff_indexing_task(source, %{force: true})

    conn
    |> put_status(:ok)
    |> json(%{message: "Index job created"})
  end

  def refresh_metadata(conn, %{"id" => id}) do
    source = Sources.get_source!(id)
    SourceMetadataStorageWorker.kickoff_with_task(source)

    conn
    |> put_status(:ok)
    |> json(%{message: "Metadata refresh job created"})
  end

  def sync_files(conn, %{"id" => id}) do
    source = Sources.get_source!(id)
    FileSyncingWorker.kickoff_with_task(source)

    conn
    |> put_status(:ok)
    |> json(%{message: "File sync job created"})
  end
end
