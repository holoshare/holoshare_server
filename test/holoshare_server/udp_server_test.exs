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

  test "Check if broadcast works with more than one client" do
    client2_port = @client_port + 1
    {:ok, _client2} = :gen_udp.open(client2_port, [:binary])
    UDPServer.broadcast(
       @name,
       "TEST",
       [
         {@localhost, @client_port},
         {@localhost, client2_port},
       ])
    assert_receive {:udp, _port, @localhost, @server_port, "TEST"}
    assert_receive {:udp, _port, @localhost, @server_port, "TEST"}
 
  end
end
