defmodule Systemex.CPU do
  require Logger

  alias __MODULE__.Stats

  def start_link() do
    {:ok, spawn_link fn ->
      Stream.interval(1000)
        |> Stream.map(&Stats.get_cpu_stats/1)
        |> Stream.transform(nil, &Stats.dedupe/2)
        |> Enum.each(&Stats.send/1)
    end}
  end

  defmodule Stats do
    def get_cpu_stats(_) do
      :cpu_sup.util |> Float.round
    end

    def dedupe(last, last), do: {[], last}
    def dedupe(el, _), do: {[el], el}

    def send(value) do
      Systemex.Connections.send_to_all(%{type: :cpu, data: %{utilization: value}})
    end
  end
end
