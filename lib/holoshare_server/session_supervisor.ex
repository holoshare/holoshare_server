defmodule HoloshareServer.SessionSupervisor do
  use DynamicSupervisor

  alias HoloshareServer.SharedSession

  @name :session_supervisor

  def start_link(_opts) do
    DynamicSupervisor.start_link(__MODULE__, :ok, [name: @name])
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(id) do
    spec = {SharedSession, name: {:global, id}}
    DynamicSupervisor.start_child(@name, spec)
  end
end
