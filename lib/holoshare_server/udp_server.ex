defmodule HoloshareServer.UDPServer do
  use GenServer
  require Logger

  alias HoloshareServer.MessageHandler

  @port Application.get_env(:holoshare_server, :udp_port, 4321)

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    with {:ok, socket} <- :gen_udp.open(@port, [{:active, true}, :binary, :inet]),
         {:ok, port} <- :inet.port(socket),
         {:ok, pid} <- MessageHandler.start_link([udp: self()])
      do
      {:ok, %{socket: socket, port: port, message_handler: pid}}
    else
      error ->
        Logger.error inspect(error)
        {:error, error}
    end
  end

  def send_message(name, ip, port, payload) do
    GenServer.cast(name, {:send_msg, ip, port, payload})
  end
  
  def broadcast(name, payload, client_list) do
    GenServer.cast(name, {:broadcast, payload, client_list})
  end

  def handle_cast({:broadcast, payload, client_list}, state) do
    for {ip, port} <- client_list do
      :gen_udp.send(state.socket, ip, port, payload)
    end
    {:noreply, state}
  end

  def handle_cast({:send_msg, ip, port, payload}, state) do
    :gen_udp.send(state.socket, ip, port, payload)
    {:noreply, state}
  end


  def handle_info({:udp, _socket, ip, port, payload}, state) do
    MessageHandler.recv_message(state[:message_handler], ip, port, payload)
    {:noreply, state}
  end

end
