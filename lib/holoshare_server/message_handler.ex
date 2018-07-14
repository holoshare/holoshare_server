defmodule HoloshareServer.MessageHandler do
  use GenServer
  require Logger

  alias HoloshareServer.Session.SessionSupervisor
  alias HoloshareServer.SharedSession
  alias HoloshareServer.UDPServer


  def start_link([{:udp, pid} | args]) do
    GenServer.start_link(__MODULE__, pid, args)
  end

  def init(udp_pid) do
    state = %{}
    |> Map.put(:udp_pid, udp_pid)
    {:ok, state}
  end

  def recv_message(pid, ip, port, obj) do
    GenServer.cast(pid, {:recv_message, ip, port, obj})
  end

  def handle_cast({:recv_message, ip, port, obj}, state) when is_binary(obj) do
    case Poison.decode(obj) do
      {:ok, obj} -> handle_message(ip, port, obj, state)
      {:error, error} ->
        Logger.error "UDP Payload parse error ... Poison.decode error"
        Logger.error inspect(error)
    end
    {:noreply, state}
  end

  def handle_cast({:recv_message, ip, port, obj}, state) do
    handle_message(ip, port, obj, state)
    {:noreply, state}
  end

  defp handle_message(ip, port, %{type: "INIT"}, state) do
    UDPServer.send_message(
      state[:udp_pid],
      ip,
      port,
      Poison.encode! %{type: "resp", text: "HELLO"}
    )
  end

end
