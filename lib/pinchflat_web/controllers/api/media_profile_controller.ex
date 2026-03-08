defmodule PinchflatWeb.Api.MediaProfileController do
  use PinchflatWeb, :controller

  alias Pinchflat.Profiles

  def index(conn, _params) do
    media_profiles = Profiles.list_media_profiles()

    conn
    |> put_status(:ok)
    |> json(%{data: media_profiles})
  end

  def show(conn, %{"id" => id}) do
    media_profile = Profiles.get_media_profile!(id)

    conn
    |> put_status(:ok)
    |> json(media_profile)
  end

  def create(conn, %{"media_profile" => media_profile_params}) do
    case Profiles.create_media_profile(media_profile_params) do
      {:ok, media_profile} ->
        conn
        |> put_status(:created)
        |> json(media_profile)

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_changeset_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id, "media_profile" => media_profile_params}) do
    media_profile = Profiles.get_media_profile!(id)

    case Profiles.update_media_profile(media_profile, media_profile_params) do
      {:ok, media_profile} ->
        conn
        |> put_status(:ok)
        |> json(media_profile)

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_changeset_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id} = params) do
    media_profile = Profiles.get_media_profile!(id)
    delete_files = params["delete_files"] == "true" || params["delete_files"] == true

    {:ok, _media_profile} = Profiles.delete_media_profile(media_profile, delete_files: delete_files)

    conn
    |> put_status(:ok)
    |> json(%{message: "Media profile deletion started"})
  end

  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%\{(\w+)\}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
