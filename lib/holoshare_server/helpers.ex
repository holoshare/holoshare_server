defmodule HoloshareServer.Helpers do

  @moduledoc """
  This module provides helper functions for repetitive tasks.
  """

  @doc """
  Converts an ip from {w, x, y, z} to string 'w.x.y.z'
    iex> HoloshareServer.Helpers.format_ip({1,2,3,4})
    "1.2.3.4"
  """
  def format_ip({_a, _b, _c, _d} = ip) do
   :inet_parse.ntoa(ip) |> to_string
  end


  @doc """
  Converts an ip from string 'w.x.y.z' to {w, x, y, z}
  
    iex> HoloshareServer.Helpers.parse_ip("1.2.3.4")
    {:ok, {1, 2, 3, 4}}
  """
  def parse_ip(str) when is_binary(str) do
    :inet.parse_address(to_charlist(str))
  end

  @doc """
  Converts an ip from string 'w.x.y.z' to {w, x, y, z}
  
    iex> HoloshareServer.Helpers.parse_ip!("1.2.3.4")
    {1, 2, 3, 4}
  """
  def parse_ip!(str) when is_binary(str) do
    case :inet.parse_address(to_charlist(str)) do
      {:ok, ip} -> ip
      error -> throw error 
    end
  end
  
  defp get_atom(str) when is_binary(str) do
    try do
      String.to_existing_atom str
    rescue
      _ -> str
    end
  end
  
  defp get_atom(str) when is_atom(str) do
    str
  end
  
  def safe_atomize_keys(nil), do: nil
  
  def safe_atomize_keys(%{__struct__: _} = struct), do: struct
  
  def safe_atomize_keys(%{} = map) do
    map
    |> Enum.map(fn {k ,v} -> {get_atom(k), safe_atomize_keys(v)} end)
    |> Enum.into(%{})
  end
  
  def safe_atomize_keys([head | rest]) do
    [safe_atomize_keys(head) | safe_atomize_keys(rest)]
  end
  
  def safe_atomize_keys(other_val), do: other_val
  
  
  def stringify_keys(nil), do: nil
  
  def stringify_keys(%{} = map) do
    map
    |> Enum.map(fn {k, v} -> {Atom.to_string(k), stringify_keys(v)} end)
    |> Enum.into(%{})
  end
  
  def stringify_keys([head | rest]) do
    [stringify_keys(head) | stringify_keys(rest)]
  end
  
  def stringify_keys(any), do: any

end
