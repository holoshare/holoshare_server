defmodule HoloshareServer.Session do
  defmodule User do
    defstruct username: nil,
      id: nil,
      ip: nil,
      port: nil
  end

  defmodule Object do
    defmodule Position do
      defstruct x: nil,
        y: nil,
        z: nil
    end

    defmodule Orientation do
      defstruct any: nil
    end

    defstruct id: nil,
      creator: nil,
      object: nil,
      position: nil,
      orientation: nil,
      size: 1,
      last_updated: nil
  end

  defstruct id: nil,
    members: [],
    objects: [],
    marker_id: 0
end
