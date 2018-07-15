defmodule HoloshareServerTest.MessageHandlerTest do
  use ExUnit.Case
  alias HoloshareServer.MessageHandler

  setup do
    {:ok, pid} = MessageHandler.start_link [udp: nil]
    %{pid: pid}
  end

  test "Check if valid JSON is handled", %{pid: pid} do
    msg = Poison.encode! %{test: 'test'}
    assert :ok == MessageHandler.recv_message(pid, nil, nil, msg)
  end
end
