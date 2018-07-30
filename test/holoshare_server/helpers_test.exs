defmodule HoloshareServerTests.HelpersTest do
  use ExUnit.Case
  doctest HoloshareServer.Helpers
  
  alias HoloshareServer.Helpers  
    
  test "Check if stringify_keys works" do
    map_with_atoms = %{a: %{b: [%{c: :d}]}}
    map_with_strings = %{"a" => %{"b" => [%{"c" => :d}]}}
    assert map_with_strings == Helpers.stringify_keys(map_with_atoms)
  end
  
  test "Check if safe_atomize_keys works" do
    map_with_atoms = %{a: %{b: [%{c: :d}]}}
    map_with_strings = %{"a" => %{"b" => [%{"c" => :d}]}}
    assert map_with_atoms == Helpers.safe_atomize_keys(map_with_strings)
  end
  
  test "Check if safe_atomize_keys does not create new atoms" do
    :this_atom_exists
    map_with_strings = %{"this_does_not_exist" => 4, "this_atom_exists" => 5}
    assert %{"this_does_not_exist" => 4, this_atom_exists: 5} == 
      Helpers.safe_atomize_keys(map_with_strings)
  end
end