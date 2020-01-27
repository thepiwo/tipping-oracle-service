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
      public: "ak_2VnwoJPQgrXvreUx2L9BVvd9BidWwpu1ASKK1AMre21soEgpRT",
      secret: ""
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
