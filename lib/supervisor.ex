defmodule TippingOracleService.Supervisor do
  @moduledoc """
  Supervisor responsible for TippingOracleService.
  """
  alias AeppSDK.Client
  use Supervisor

  def start_link(_args) do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    keypair = %{
      public: "ak_2WRZ6FqDStG2MHaP9GsiTT4CNDp7C86PXghrd7eSdVooMmdPc5",
      secret: "8441df10047f52d12424c57cc8a2fa560d0e7391206084da923af2cdf5721131c6816002cea696b668c7270b0a3fb7c00aea4997ffa5ca05b2f329ae08a750e7"
    }

    client = Client.new(
      keypair,
      "ae_uat",
      "https://testnet.aeternity.art/v2",
      "https://testnet.aeternity.art/v2",
      gas_price: 1_000_000_000
    )

    children = [
      {TippingOracleService, [client]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
