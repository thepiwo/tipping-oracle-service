defmodule TippingOracleService do
  use GenServer
  alias AeppSDK.{Account, Listener}
  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init([client]) do
    Listener.start("ae_uat")
    Listener.subscribe(:spend_transactions, self(), client.keypair.public)

    {:ok, %{client: client}}
  end

  def make_spend, do: GenServer.call(__MODULE__, :make_spend)

  def handle_call(:make_spend, _from, %{client: client} = state) do
    spend = Account.spend(client, client.keypair.public, 10_000_000)
    {:reply, spend, state}
  end

  def handle_info({:spend_transactions, _, spend_transaction}, state) do
    Logger.info(fn -> "Received new spend transaction: #{inspect(spend_transaction)}" end)
    {:noreply, state}
  end

  def stop do
    Listener.stop()
  end
end
