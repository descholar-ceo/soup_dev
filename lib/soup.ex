defmodule Soup do
  def enter_select_location_flow do
    IO.puts "Wait a moment while I fetch locations for you"
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
            IO.puts "You have elected #{location["name"]}"
            File.write!(Path.expand(@config_file), to_string(:erlang.term_to_binary(location)))
            {:ok, location}
        end
    end
  end
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
end
