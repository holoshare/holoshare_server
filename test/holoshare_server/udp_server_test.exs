defmodule HoloshareServerTest.UDPServerTest do
  use ExUnit.Case

  alias HoloshareServer.UDPServer

  @name :test_udp
  @localhost {127, 0, 0, 1}
  @client_port 4322
  @server_port Application.get_env(:holoshare_server, :udp_port, 4321)

  setup do
    {:ok, pid} = UDPServer.start_link([name: @name])
    {:ok, client} = :gen_udp.open(@client_port, [:binary])
    %{server: pid, client: client}
  end

  test "Make sure the UDP server is up and running", %{client: client} do
    assert :ok == :gen_udp.send(client, @localhost, @server_port, "{TEST")
  end

  test "Send message to client" do
    UDPServer.send_message(@name, @localhost, @client_port, "TEST")
    assert_receive {:udp, _port, @localhost, @server_port, "TEST"}
  end
end
