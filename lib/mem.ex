defmodule Systemex.Mem do
  require Logger

  alias __MODULE__.Stats

  def start_link() do
    stream = Stream.interval(1000)
      |> Stream.map(&Stats.get_mem_stats/1)
      |> Streamz.dedupe
      |> Stream.map(&Stats.build_message/1)
    [conn | []] = EventSource.add_handler(stream, __MODULE__.Stats)
    Process.link(conn.pid)
    {:ok, conn.pid}
  end

  defmodule Stats do
    def start_link(options \\ []) do
      GenEvent.start_link Keyword.put_new(options, :name, __MODULE__)
    end

    def get_mem_stats(_) do
      data = {total, used, _} = :memsup.get_memory_data
      Float.round(100 * used/total, 2)
    end

    def build_message(value) do
      %{type: :mem, data: %{utilization: value}}
    end
  end
end
