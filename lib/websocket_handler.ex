defmodule Systemex.WebsocketHandler do

  require Logger

  defmodule Handler do
    use GenEvent

    def init(pid) do
      {:ok, pid}
    end

    def handle_event(msg, pid) do
      send pid, msg
      {:ok, pid}
    end
  end

  def init(_, request, opts, _) do
    sources = Keyword.get(opts, :sources, [])
      |> Enum.flat_map &EventSource.add_handler(GenEvent.stream(&1), self)
    {:ok, request, sources}
  end

  def stream(_, request, state) do
    {:ok, request, state}
  end

  def info({_, tag, {:ack_notify, message}}, request, state) do
    :gen.reply(tag, :ok)
    reply(message, request, state)
  end

  def info({_, tag, {:ack_notify, message}}, request, state) do
    :gen.reply(tag, :ok) # Until we have sync across websocket, this is the end of the road
    reply(message, request, state)
  end

  def info({_, tag, {:notify, message}}, request, state) do
    reply(message, request, state)
  end

  defp reply(message, request, state) do
    data = Poison.encode!(message)
    {:reply, data, request, state}
  end

  def terminate(_, sources) do
    Enum.each sources, fn(connection) ->
      EventSource.Connection.remove_handler(connection)
    end
    :ok
  end
end
