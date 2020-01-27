defmodule TippingOracleService do
  use GenServer
  alias AeppSDK.{Account, Listener, Oracle, Utils.Hash, Utils.Encoding}
  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init([client]) do
    Listener.start(client.network_id)
    Listener.subscribe(:oracle_queries, self(), "ok_2WRZ6FqDStG2MHaP9GsiTT4CNDp7C86PXghrd7eSdVooMmdPc5")

    {:ok, %{client: client}}
  end

  def handle_info({:oracle_queries, _, oracle_query}, %{client: client} = state) do
    query_id = compute_query_id(oracle_query)
    Logger.info(fn -> "Received new oracle query " <> query_id <> ": #{inspect(oracle_query)}" end)
    Oracle.respond(client, oracle_query.tx.oracle_id, query_id, "world", 1_000)
    {:noreply, state}
  end

  def stop do
    Listener.stop()
  end

  defp compute_query_id(oracle_query) do
    oracle_sender = Encoding.prefix_decode_base58c(oracle_query.tx.sender_id)
    oracle_id = Encoding.prefix_decode_base58c(oracle_query.tx.oracle_id)
    {:ok, hash} = Hash.hash(<<oracle_sender :: binary, oracle_query.tx.nonce :: size(256), oracle_id :: binary>>)
    Encoding.prefix_encode_base58c("oq", hash)
  end
end
