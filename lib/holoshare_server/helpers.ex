defmodule HoloshareServer.Helpers do

  def format_ip({_a, _b, _c, _d} = ip) do
   :inet_parse.ntoa(ip) |> to_string
  end

  def parse_ip(str) when is_binary(str) do
    :inet.parse_address(to_charlist(str))
  end

  def parse_ip!(str) when is_binary(str) do
    case :inet.parse_address(to_charlist(str)) do
      {:ok, ip} -> ip
      error -> throw error 
    end
  end
end
