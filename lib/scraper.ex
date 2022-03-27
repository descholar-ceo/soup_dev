defmodule Scraper do
  @moduledoc """
  It contains all of the scraping logic.
  """

  @spec get_locations :: :error | {:ok, list}
  @doc """
  It gets a list of all locations from the url: https://www.haleandhearty.com/locations/
  """
  def get_locations do
    case HTTPoison.get "https://www.haleandhearty.com/locations/" do
      {:ok, response} ->
        case response.status_code do
          200 ->
            locations =
              response.body
              |>Floki.find(".location-card")
              |>Enum.map(&extract_location_name_and_id/1)
              |>Enum.sort(&(&1["id"] < &2["id"]))

            {:ok, locations}
          _ -> :error
        end
      _ -> :error
    end
  end

  defp extract_location_name_and_id({_tag, attrs, children}) do
    {_, _, [name]}=
    children
    |> Floki.find(".location-card__name")
    |> hd()

    attrs = Enum.into(attrs, %{})
    %{id: attrs["id"], name: name}
  end
end
