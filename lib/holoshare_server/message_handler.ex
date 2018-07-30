defmodule HoloshareServer.MessageHandler do
  use GenServer
  require Logger

  alias HoloshareServer.SessionSupervisor
  alias HoloshareServer.SharedSession
  alias HoloshareServer.UDPServer
  alias HoloshareServer.Helpers


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
      {:ok, obj} -> handle_message(ip, port, Helpers.safe_atomize_keys(obj), state)
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

  defp handle_message(ip, port, %{type: "INIT"} = msg, state) do
    session_pid = SessionSupervisor.get_session(msg[:session_id])
    session = case session_pid do 
      nil -> nil
      pid -> SharedSession.get_session(pid)
    end
    UDPServer.send_message(
      state[:udp_pid],
      ip,
      port,
      Poison.encode! %{type: "FULL_SESSION", session: session}
    )
  end

  defp handle_message(ip, port, %{type: "ACTION"} = msg, state) do
    if SessionSupervisor.session_exists?(msg[:session_id]) do
      session_pid = SessionSupervisor.get_session(msg[:session_id])
      result = SharedSession.preform_action(session_pid, msg[:data])
      UDPServer.broadcast(state[:udp_pid], Poison.encode!(%{data: result, type: "CHANGE"}), [{ip, port}])
    end
    SessionSupervisor.get_session(msg[:session_id])
  end

  defp handle_message(_ip, _port, msg, _state) do
    Logger.debug "Unhandled message"
    Logger.debug inspect(msg)
  end

end
