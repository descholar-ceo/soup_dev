defmodule Soup.CLI do
  def main argv do
    IO.puts argv
    argv
    |>parse_args
    |>process
  end

  def parse_args argv do
    args = OptionParser.parse(
      argv, strict: [help: :boolean, locations: :boolean],
      alias: [h: :help]
    )
    case args do
      {:help, _, _} ->
        :help

      {[], [], [{"-h", nil}]} ->
        :help

      {[locations: true], _, _} ->
        :list_locations

      {[], [], []} ->
        :list_soups

      _ ->
        :invalid_tag
    end
  end

  def process :help do
    IO.puts """
    soup --locations  # Select a default location whose soups you want to list
    soup        # List the soups for a default location (you'll be prompted to select a default location if you haven't already)
    """
    System.halt 0
  end
  def process :list_locations do
    Soup.enter_select_location_flow
  end
  # def process :list_soups do
  #   Soup.fetch_soup_list
  # end
  def process :invalid_tag do
    IO.puts "Invalid argument(s) passed. See usage below:"
    process(:help)
  end
end
