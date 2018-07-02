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
         {:ok, port} <- :inet.port(socket)
      do
      {:ok, %{socket: socket, port: port}}
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
    case Poison.decode(payload) do
      {:ok, obj} -> MessageHandler.handle_message(ip, port, obj)
      {:error, error} ->
        Logger.error "UDP Payload parse error ... Poison.decode error"
        Logger.error inspect(error)
    end
    {:noreply, state}
  end

end
