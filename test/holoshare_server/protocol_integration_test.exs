defmodule HoloshareServerTest.ProtocolIntegrationTest do
  use ExUnit.Case

  alias HoloshareServer.UDPServer

  @name :test_udp
  @localhost {127, 0, 0, 1}
  @client_port 4322
  @server_port Application.get_env(:holoshare_server, :udp_port, 4321)

  setup do
    {:ok, pid} = UDPServer.start_link [name: @name]
    {:ok, client} = :gen_udp.open(@client_port, [:binary])
    %{server: pid, client: client}
  end

  test "Check if INIT works", %{client: client} do
    msg = Poison.encode! %{type: "INIT"}
    :gen_udp.send(client, @localhost, @server_port, msg)
    assert_receive {:udp, _port, @localhost, @server_port, resp}, 500
    assert Poison.decode!(resp) == %{"type" => "resp", "text" => "HELLO"}
  end
end
