defmodule Systemex.WebsocketHandler do

  require Logger

  def init(_, request, _, _) do
    Systemex.Connections.add self
    Systemex.Connections.send_latest_to_pid self
    {:ok, request, nil}
  end

  def stream(message, request, state) do
    Logger.info("message received: #{inspect message}")
    {:ok, request, state}
  end

  def info({:text, message}, request, state) do
    {:reply, Poison.encode!(message), request, state}
  end

  def terminate(_, _) do
    :ok
  end
end
