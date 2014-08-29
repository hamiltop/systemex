defmodule Systemex.Mem do
  require Logger

  alias __MODULE__.Stats

  def start_link() do
    {:ok, spawn_link fn ->
      Stream.interval(1000)
        |> Stream.map(&Stats.get_mem_stats/1)
        |> Stream.transform(nil, &Stats.dedupe/2)
        |> Enum.each(&Stats.send/1)
    end}
  end

  defmodule Stats do
    def get_mem_stats(_) do
      {total, used, _} = :memsup.get_memory_data
      Float.round(100 * used/total, 2)
    end

    def dedupe(last, last), do: {[], last}
    def dedupe(el, _), do: {[el], el}

    def send(value) do
      Systemex.Connections.send_to_all(%{type: :mem, data: %{utilization: value}})
    end
  end
end
