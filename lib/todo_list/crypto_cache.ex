defmodule TodoList.CryptoCache do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    {:ok, nil}
  end

  def get_rate do
    GenServer.call(__MODULE__, :get_rate)
  end

  def update_rate(rate) do
    GenServer.cast(__MODULE__, {:update_rate, rate})
  end

  def handle_call(:get_rate, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:update_rate, rate}, _state) do
    {:noreply, rate}
  end
end
