defmodule HoloshareServerTest.SessionSupervisorTest do
  use ExUnit.Case

  alias HoloshareServer.SessionSupervisor

  setup do
    {:ok, pid} = SessionSupervisor.start_link([])
    %{pid: pid}
  end

  test "Check if supervisor can start child" do
    id = UUID.uuid4
    {:ok, pid} = SessionSupervisor.start_child(id)
    assert pid == :global.whereis_name id
  end
  
  test "Check if supervisor can retrieve session" do
    id = UUID.uuid4
    {:ok, pid} = SessionSupervisor.start_child(id)
    assert pid == SessionSupervisor.get_session(id)
  end
  
  test "Check if supervisor will create session if not found" do
    id = UUID.uuid4
    pid = SessionSupervisor.get_session(id)
    assert pid == :global.whereis_name id
  end
  
  test "Check if session_exists works" do
   id = UUID.uuid4
   assert SessionSupervisor.session_exists?(id) == false
   SessionSupervisor.start_child(id)
   assert SessionSupervisor.session_exists?(id) == true
  end
end
