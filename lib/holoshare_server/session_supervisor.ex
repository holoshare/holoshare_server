defmodule HoloshareServer.SessionSupervisor do
  use DynamicSupervisor
  require Logger

  alias HoloshareServer.SharedSession

  @name :session_supervisor

  def start_link(_opts) do
    DynamicSupervisor.start_link(__MODULE__, :ok, [name: @name])
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(id) do
    spec = {SharedSession, name: {:global, id}, session_id: id, marker_id: id}
    DynamicSupervisor.start_child(@name, spec)
  end
  
  def get_session(id) do
    case :global.whereis_name(id) do
      :undefined -> 
        {:ok, pid} = start_child(id)
        pid
      pid -> pid
    end
  end
  
  def session_exists?(id) do
    case :global.whereis_name(id) do
      :undefined -> false
      _ -> true
    end
  end
end
