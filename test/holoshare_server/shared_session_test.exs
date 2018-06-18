defmodule HoloshareServerTest.SharedSessionTest do
  use ExUnit.Case
  alias HoloshareServer.SharedSession
  alias HoloshareServer.Session

  @name :test_session
  @test_member %{name: "Test", id: 3}
  @test_object %{
    position: %{x: 12, y: 12, z: 12},
    orientation: %{},
    size: 1,
    type: "sphere",
    id: 4
  }
  @test_change_action %{
    type: "change",
    action: %{
      id: 4,
      position: %{x: 12, y: -24, z: 0},
      size: 0.4
    }
  }
  @changed_object %{
    id: 4,
    position: %{x: 24, y: -12, z: 12},
    size: 1.4,
    type: "sphere",
    orientation: %{}
  }
  @test_add_action %{
    type: "add",
    action: @test_object
  }
  @test_remove_action %{
    type: "remove",
    action: %{
      id: 4
    }
  }


  setup do
    SharedSession.start_link(name: @name, marker_id: 1)
    %{}
  end

  test "Get session" do
    assert SharedSession.get_session(@name) ==
      struct(Session, %{marker_id: 1})
  end

  test "Add member to session" do
    SharedSession.add_member(@name, @test_member)
    assert SharedSession.get_session(@name).members == [@test_member]
  end

  test "Remove member from session" do
    SharedSession.add_member(@name, @test_member)
    assert SharedSession.get_session(@name).members == [@test_member]

    SharedSession.remove_member(@name, @test_member)
    assert SharedSession.get_session(@name).members == []
  end

  test "Add object to session" do
    SharedSession.add_object(@name, @test_object)
    assert SharedSession.get_session(@name).objects == [@test_object]
  end

  test "Remove object from session" do
    SharedSession.add_object(@name, @test_object)
    assert SharedSession.get_session(@name).objects == [@test_object]

    SharedSession.remove_object(@name, @test_object)
    assert SharedSession.get_session(@name).objects == []
  end

  test "Preform action change" do
    SharedSession.add_object(@name, @test_object)
    SharedSession.preform_action(@name, @test_change_action)
    obj = SharedSession.get_object(@name, @test_object[:id])
    assert obj == @changed_object
  end

  test "Preform action add" do
    SharedSession.preform_action(@name, @test_add_action)
    assert SharedSession.get_session(@name).objects == [@test_object]
  end

  test "Preform action remove" do
    SharedSession.add_object(@name, @test_object)
    assert SharedSession.get_session(@name).objects == [@test_object]

    SharedSession.preform_action(@name, @test_remove_action)
    assert SharedSession.get_session(@name).objects == []
  end

end
