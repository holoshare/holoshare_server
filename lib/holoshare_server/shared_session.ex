defmodule HoloshareServer.SharedSession do
  use Agent
  alias HoloshareServer.Session

  def start_link(opts) do
    Agent.start_link(fn ->
      struct(
        Session,
        %{
          marker_id: opts[:marker_id],
          id: opts[:session_id]
        }
      )
    end, opts)
  end

  defp update_object_in_list(objects, obj) do
    index = Enum.find_index(objects, &(&1[:id] == obj[:id]))
    List.update_at(objects, index,
      &(Map.merge(&1, obj,
            fn
              :id, x, _y -> x
              _k, %{x: x, y: y, z: z}, %{x: a, y: b, z: c} ->
                %{x: x + a, y: y + b, z: z + c}
              k, l, r when k in [:size]->
                l + r
              k, _l, r when k in [:type] ->
                r
            end
          )))
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
    obj
  end

  def remove_object(name, obj) do
    Agent.update(name,
      fn x -> Map.put(x, :objects, Enum.filter(x.objects, &(&1.id != obj.id))) end)
  end

  def get_object(name, obj_id) do
    Agent.get(name,
      &(Enum.find(&1.objects, fn x -> match?(%{id: obj_id}, x) end)))
  end

  def update_object(name, obj) do
    new_object_list = get_session(name)
    |> Map.get(:objects)
    |> update_object_in_list(obj)
    Agent.update(name,
      &(Map.put(&1, :objects, new_object_list)))
    get_session(name)
    |> Map.get(:objects)
    |> Enum.find(fn x -> x[:id] == obj[:id] end)
  end

  def preform_action(name, %{type: "add", action: action}) do
    add_object(name, action)
    %{objects: [action]}
  end

  def preform_action(name, %{type: "change", action: action}) do
    %{objects: [update_object(name, action)]}
  end

  def preform_action(name, %{type: "remove", action: action}) do
    remove_object(name, action)
    %{removed_objects: [action[:id]]}
  end

  def preform_action(name, _action) do
    Agent.update(name, fn x -> x end)
  end
end
