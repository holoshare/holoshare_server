defmodule HoloshareServer.SharedSession do
  use Agent
  alias HoloshareServer.Session

  def start_link(opts) do
    Agent.start_link(fn ->
          struct(
            Session,
            %{
              marker_id: opts[:marker_id]
            }
          )
       end, opts)
  end

  def get_session(name) do
    Agent.get(name, &(&1))
  end

  def update_session(name, session) do
    Agent.update(name, fn x ->
      Map.merge(x, session)
    end)
  end

  def add_member(name, member) do
    Agent.update(name,
      fn x -> Map.put(x, :members, [member | x.members]) end)
  end

  def remove_member(name, member) do
    Agent.update(name,
    fn x -> Map.put(x, :members, List.delete(x.members, member)) end)
  end

  def add_object(name, obj) do
    Agent.update(name,
    fn x -> Map.put(x, :objects, [obj | x.objects]) end)
  end

  def remove_object(name, obj) do
    Agent.update(name,
    fn x -> Map.put(x, :objects, List.delete(x.objects, obj)) end)
  end

  def get_object(name, obj_id) do
    Agent.get(name,
    &(Enum.find(&1.objects, fn x -> match?(%{id: obj_id}, x) end)))
  end

  def update_object(name, obj) do
    Agent.update(name,
      fn x ->
        Map.put(x, :objects,
          Enum.map(x.objects,
            fn x ->
              if obj.id == x.id do
                obj
              else
                x
              end
            end
          )
        )
      end
    )
  end

  def preform_action(name, %{type: "add", action: action}) do
    add_object(name, action)
  end

  def preform_action(name, _action) do
    Agent.update(name, fn x -> x end)
  end
 end
