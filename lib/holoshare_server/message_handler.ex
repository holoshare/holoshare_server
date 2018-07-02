defmodule HoloshareServer.MessageHandler do
  use GenServer

  def handle_message(ip, port, %{session_id: session_id, user_id: user_id} = obj) do
  end

end
