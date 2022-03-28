defmodule Soup do
  @moduledoc """
  It contains all of the functions which deal with the CLI logic.
  """
  @spec enter_select_location_flow :: :ok
  def enter_select_location_flow do
    IO.puts "\tWait a moment while I fetch locations for you
    =======================================================
    "
    locations = Scraper.get_locations
    case locations do
      {:ok, locations} ->
        {:ok, location} = ask_user_to_select_location locations
        display_soup_list location
      _ ->
        IO.puts "Error fetching locations"
    end
  end
  @config_file "~/.soup"

  @spec ask_user_to_select_location(any) :: {:ok, maybe_improper_list | map}
  @doc """
  Prompt the user to select a location whose soup list they want to view.

  The location's name and ID will be saved to @config_file  for future lookups.
  This function can only ever return a {:ok, location} tuple because an invalid
  selection will result in this funtion being recursively called.
  """
  def ask_user_to_select_location locations do
    locations
    |>Enum.with_index(1)
    |>Enum.each(fn({location, index}) -> IO.puts "#{index} - #{location.name}" end)

    case IO.gets("Select a location number:") |> Integer.parse() do
      :error ->
        IO.puts "Invalid selection"
        ask_user_to_select_location locations
      {location_number, _} ->
        case Enum.at locations, location_number - 1 do
          nil ->
            IO.puts "Invalid selection"
            ask_user_to_select_location locations
          location ->
            IO.puts "You have elected #{location.name}"
            File.write!(Path.expand(@config_file), to_string(:erlang.term_to_binary(location)))
            {:ok, location}
        end
    end
  end
  @spec display_soup_list(atom | %{:id => any, :name => any, optional(any) => any}) :: :ok
  def display_soup_list location do
    IO.puts "One moment while I fetch today's soup list for #{location.name}..."
    soups = Scraper.get_soups location.id
    case soups do
      {:ok, soups} ->
        IO.puts "The list of available meals is:"
        Enum.each(soups, &(IO.puts " -> " <> &1))
      _ ->
        IO.puts "Error fetching soups"
    end
  end
  @spec get_saved_location ::
          :error
          | {:empty_location_id}
          | {:ok, atom | %{:id => binary, optional(any) => any}}
          | %{:__exception__ => true, :__struct__ => atom, optional(atom) => any}
  @doc """
  It get location name saved on ~/.soup file
  """
  def get_saved_location do
    case Path.expand(@config_file) |> File.read() do
      {:ok, location} ->
        try do
          location = :erlang.binary_to_term(location)
          case String.trim(location.id) do
            "" -> {:empty_location_id}
            _ -> {:ok,location}
          end
        rescue
          e in ArgumentError -> e
        end
      {:error, _} ->
        :error
    end
  end

  @spec fetch_soup_list :: :ok
  @doc """
  It fetches soup list
  """
  def fetch_soup_list do
    case get_saved_location() do
      {:ok, location} ->
        display_soup_list(location)
      _ ->
        IO.puts "You haven't selected a default location, kindly select one below"
        enter_select_location_flow()
    end
  end
end
