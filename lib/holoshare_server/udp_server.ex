defmodule HoloshareServer.UDPServer do
  use GenServer
  require Logger

  alias HoloshareServer.Helpers
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


  def handle_cast({:send_msg, ip, port, payload}, state) do
    :gen_udp.send(state.socket, ip, port, payload)
    {:noreply, state}
  end


  def handle_info({:udp, socket, ip, port, payload}, state) do
    Logger.debug "#{inspect socket} [#{Helpers.format_ip(ip)}] #{inspect port}: #{payload}"
    MessageHandler.recv_message(state[:message_handler], ip, port, payload)
    {:noreply, state}
  end

end
