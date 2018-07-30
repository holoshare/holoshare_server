defmodule HoloshareServerTest.ProtocolIntegrationTest do
  use ExUnit.Case

  alias HoloshareServer.UDPServer
  alias HoloshareServer.SessionSupervisor
  alias HoloshareServer.SharedSession
  alias HoloshareServer.Helpers
  alias HoloshareServer.Session

  @name :test_udp
  @localhost {127, 0, 0, 1}
  @client_port 4322
  @server_port Application.get_env(:holoshare_server, :udp_port, 4321)
  @user_id 5
  @session_id "test-session"
  @test_object %{
    position: %{x: 12, y: 12, z: 12},
    orientation: %{},
    size: 1,
    type: "sphere",
    id: 4
  }
  @test_change_action %{
    type: "change",
    action: %{
      id: 4,
      position: %{x: 12, y: -24, z: 0},
      size: 0.4
    }
  }
  @changed_object %{
    id: 4,
    position: %{x: 24, y: -12, z: 12},
    size: 1.4,
    type: "sphere",
    orientation: %{}
  }
  @test_add_action %{
    type: "add",
    action: @test_object
  }
  @test_remove_action %{
    type: "remove",
    action: %{
      id: 4
    }
  }

  setup do
    {:ok, pid} = UDPServer.start_link [name: @name]
    {:ok, _} = SessionSupervisor.start_link []
    {:ok, client} = :gen_udp.open(@client_port, [:binary])
    %{server: pid, client: client}
  end

  defp add_generic_member(session_id) do
    pid = SessionSupervisor.get_session(session_id)
    SharedSession.add_member(pid, %Session.User{ip: Helpers.format_ip(@localhost), port: @client_port})
  end

  test "Check if INIT works", %{client: client} do
    msg = Poison.encode!(%{
      type: "INIT",
      username: @user_id,
      session_id: @session_id
    })
    :gen_udp.send(client, @localhost, @server_port, msg)
    assert_receive {:udp, _port, @localhost, @server_port, resp}, 500
    assert Poison.decode!(resp) == %{
      "type" => "FULL_SESSION",
      "session" => %{
        "id" => @session_id,
        "marker_id" => @session_id,
        "members" => [
          %{
            "username" => @user_id,
            "ip" => "127.0.0.1",
            "port" => @client_port,
            "id" => nil
          },
        ],
        "objects" => []
      }}
  end

  test "Check if ACTION works with add", %{client: client} do
    SessionSupervisor.start_child(@session_id)
    add_generic_member(@session_id)
    msg = Poison.encode! %{
      type: "ACTION",
      user_id: @user_id,
      session_id: @session_id,
      data: @test_add_action,
    }
    :gen_udp.send(client, @localhost, @server_port, msg)
    assert_receive {:udp, _port, @localhost, @server_port, resp}, 1000
    assert Poison.decode!(resp) == 
      Helpers.stringify_keys(
        %{type: "CHANGE", data: %{objects: [@test_object]}})
  end

  test "Check if ACTION works with change", %{client: client} do
    {:ok, session_pid} = SessionSupervisor.start_child(@session_id)
    add_generic_member(@session_id)
    SharedSession.add_object(session_pid, @test_object)
    msg = Poison.encode! %{
      type: "ACTION",
      user_id: @user_id,
      session_id: @session_id,
      data: @test_change_action
    }
    :gen_udp.send(client, @localhost, @server_port, msg)
    assert_receive {:udp, _port, @localhost, @server_port, resp}
    assert Poison.decode!(resp) ==
      Helpers.stringify_keys(
        %{type: "CHANGE", data: %{objects: [@changed_object]}})
  end

  test "Check if ACTION works with delete", %{client: client} do
    {:ok, session_pid} = SessionSupervisor.start_child(@session_id)
    add_generic_member(@session_id)
    SharedSession.add_object(session_pid, @test_object)
    msg = Poison.encode! %{
      type: "ACTION",
      user_id: @user_id,
      session_id: @session_id,
      data: @test_remove_action,
    }
    :gen_udp.send(client, @localhost, @server_port, msg)
    assert_receive {:udp, _port, @localhost, @server_port, resp}
    assert Poison.decode!(resp) ==
      Helpers.stringify_keys(
        %{type: "CHANGE", data: %{removed_objects: [@test_object[:id]]}})
  end
end
