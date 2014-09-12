defmodule Systemex.WebsocketHandler do

  require Logger

  def sync_notify(pid, message) do
    {:ok, :ok} = :gen.call(pid, 'bullet', message, :infinity)
  end

  def init(_, request, _, _) do
    Systemex.Connections.add self
    Task.start_link fn ->
      Systemex.Connections.send_latest_to_pid self
    end
    {:ok, request, %{}}
  end

  def stream(message = "{\"ref\":\"" <> _, request, state) do
    message = Poison.decode!(message)
    {target, new_state} = Dict.pop(state, message["ref"])
    :gen.reply target, :ok
    {:ok, request, new_state}
  end

  def info({'bullet', from, {:text, message}}, request, state) do
    ref = :binary.bin_to_list(:crypto.rand_bytes(16)) |> Enum.map(fn
      (x) when x < 160 -> div(x, 16) + 48
      (x) when x >= 160 and x < 256 -> ?a + (div(x, 16) - 10)
    end) |> List.to_string
    {:reply, Poison.encode!(%{message: message, ref: ref}), request, Dict.put(state, ref, from)}
  end

  def info(msg, req, state) do
    {:ok, req, state}
  end

  def terminate(_, _) do
    :ok
  end
end
