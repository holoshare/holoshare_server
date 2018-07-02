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
end
