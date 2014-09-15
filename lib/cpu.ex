defmodule Systemex.CPU do
  require Logger

  alias __MODULE__.Stats

  def start_link() do
    cpu_stream =Stream.interval(1000)
      |> Stream.map(&Stats.get_cpu_stats/1)
      |> Streamz.dedupe
      |> Stream.map(&Stats.build_message/1)
    [conn | []] = EventSource.add_handler(cpu_stream, __MODULE__.Stats)
    Process.link(conn.pid)
    {:ok, conn.pid}
  end

  defmodule Stats do
    
    def start_link(options \\ []) do
      GenEvent.start_link Keyword.put_new(options, :name, __MODULE__)
    end
    
    def get_cpu_stats(_) do
      :cpu_sup.util |> Float.round
    end

    def build_message(value) do
      %{type: :cpu, data: %{utilization: value}}
    end
  end
end
