defmodule Systemex.Connections do
  require Logger

  def start_link() do
    Agent.start_link(fn -> %{latest: %{mem: nil, cpu: nil}, connections: []} end, name: __MODULE__)
  end

  def send_to_all(message = %{type: type}) do
    pids = Agent.get_and_update(__MODULE__,
      fn (state = %{latest: latest, connections: connections}) ->
        {connections, %{state | :latest => Map.put(latest, type, message)}}
      end)
    Enum.each pids, fn (pid) ->
      send pid, {:text, message}
    end
  end

  def add(pid) do
    Agent.update(__MODULE__,
      fn (state = %{connections: connections}) ->
        %{state | :connections => [pid | connections]}
      end)
  end

  def remove(pid) do
    Agent.update(__MODULE__, 
      fn (state = %{connections: connections}) ->
        %{state | :connections => List.delete(connections, pid)}
      end)
  end

  def send_latest_to_pid(pid) do
    latest = Agent.get(__MODULE__,
      fn (%{latest: latest}) ->
        latest
      end)
    Map.values(latest) |> Enum.each fn (el) ->
      send pid, {:text, el}
    end
  end
end
