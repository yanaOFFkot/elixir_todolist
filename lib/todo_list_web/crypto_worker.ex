defmodule TodoListWeb.CryptoWorker do
  use GenServer
  require Logger
  alias TodoList.CryptoCache

  @interval 30_000

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    case CryptoCache.get_rate() do
      nil -> send(self(), :work)
      _ -> schedule_work()
    end
    {:ok, state}
  end

  def handle_info(:work, state) do
    fetch_crypto_rate()
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work do
    Process.send_after(self(), :work, @interval)
  end

  defp fetch_crypto_rate do
    Logger.debug("Fetching crypto rate...")
    finch_name = Application.get_env(:todo_list, :finch_name)

    case Finch.build(:get, "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd")
         |> Finch.request(finch_name) do
      {:ok, %{status: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"bitcoin" => %{"usd" => rate}}} ->
            Logger.debug("Decoded rate: #{rate}")
            CryptoCache.update_rate(rate)
            Phoenix.PubSub.broadcast(TodoList.PubSub, "crypto_rate", {:rate_updated, rate})
          _ ->
            Logger.error("Unexpected response format from API")
        end
      {:ok, %{status: 429}} ->
        Logger.warning("Rate limit exceeded. Retrying in 60 seconds.")
        Process.send_after(self(), :work, 60_000)
      {:error, reason} ->
        Logger.error("Failed to fetch cryptocurrency rate: #{inspect(reason)}")
    end
  end
end
