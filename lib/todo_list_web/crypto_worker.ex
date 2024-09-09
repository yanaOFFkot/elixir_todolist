defmodule TodoListWeb.CryptoWorker do
  use GenServer
  require Logger
  alias TodoList.CryptoCache

  @interval 30_000
  @api_url "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd"

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    schedule_work(0)
    {:ok, state}
  end

  def handle_info(:work, state) do
    fetch_crypto_rate()
    schedule_work(@interval)
    {:noreply, state}
  end

  def fetch_rate do
    send(__MODULE__, :work)
  end

  defp schedule_work(interval) do
    Process.send_after(self(), :work, interval)
  end

  defp fetch_crypto_rate do
    Logger.debug("Fetching crypto rate...")
    finch_name = Application.get_env(:todo_list, :finch_name)

    case Finch.build(:get, @api_url) |> Finch.request(finch_name) do
      {:ok, %{status: 200, body: body}} ->
        handle_successful_response(body)
      {:ok, %{status: 429}} ->
        handle_rate_limit_exceeded()
      {:error, reason} ->
        Logger.error("Failed to fetch cryptocurrency rate: #{inspect(reason)}")
    end
  end

  defp handle_successful_response(body) do
    case Jason.decode(body) do
      {:ok, %{"bitcoin" => %{"usd" => rate}}} ->
        Logger.debug("Decoded rate: #{rate}")
        CryptoCache.update_rate(rate)
        Phoenix.PubSub.broadcast(TodoList.PubSub, "crypto_rate", {:rate_updated, rate})
      _ ->
        Logger.error("Unexpected response format from API")
    end
  end

  defp handle_rate_limit_exceeded do
    Logger.warning("Rate limit exceeded. Retrying in 60 seconds.")
    schedule_work(60_000)
  end
end
