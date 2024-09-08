defmodule TodoListWeb.CryptoRateComponent do
  use Surface.LiveComponent
  require Logger
  alias Phoenix.PubSub
  alias TodoList.CryptoCache

  data crypto_rate, :string, default: "Fetching rate..."
  data last_updated, :string, default: nil

  def mount(socket) do
    Logger.info("CryptoRateComponent mounted")
    if connected?(socket) do
      Logger.info("Subscribing to crypto_rate topic")
      PubSub.subscribe(TodoList.PubSub, "crypto_rate")
      send(self(), :load_initial_rate)
    end
    {:ok, socket}
  end

  def handle_info(:load_initial_rate, socket) do
    case CryptoCache.get_rate() do
      {nil, _} ->
        send(TodoListWeb.CryptoWorker, :work)
        {:noreply, socket}
      {rate, last_updated} ->
        if DateTime.diff(DateTime.utc_now(), last_updated, :second) > 300 do
          send(TodoListWeb.CryptoWorker, :work)
        end
        {:noreply, assign(socket, crypto_rate: to_string(rate), last_updated: format_datetime(last_updated))}
    end
  end

  def handle_info({:rate_updated, rate}, socket) do
    Logger.info("Received rate update: #{rate}")
    {:noreply, assign(socket, crypto_rate: to_string(rate), last_updated: format_datetime(DateTime.utc_now()))}
  end

  def render(assigns) do
    ~F"""
    <div class="bg-white shadow-lg rounded-lg p-6 max-w-sm mx-auto mt-10">
      <div class="flex items-center justify-between mb-4">
        <div class="flex items-center">
          <img src="https://cryptologos.cc/logos/bitcoin-btc-logo.png" alt="Bitcoin logo" class="w-10 h-10 mr-2"/>
          <h2 class="text-xl font-bold text-gray-800">Bitcoin Price</h2>
        </div>
        <div class="bg-yellow-500 text-white text-xs font-bold px-2 py-1 rounded-full">LIVE</div>
      </div>
      <div class="text-3xl font-bold text-gray-900 mb-2">
        ${@crypto_rate} USD
      </div>
      <div class="text-sm text-gray-500">
        Last updated: {@last_updated || "Updating..."}
      </div>
    </div>
    """
  end

  defp format_datetime(datetime) do
    datetime
    |> DateTime.to_naive()
    |> NaiveDateTime.to_string()
    |> String.replace(~r/\.\d+/, "")
  end
end
