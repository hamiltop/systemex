defmodule Systemex do
  use Application

  require Logger
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Logger.info "Starting"

    dispatch = :cowboy_router.compile [
      {:_, [
          {"/", :cowboy_static, {:priv_file, :systemex, "index.html"}},
          {"/bullet.js", :cowboy_static, {:priv_file, :bullet, "bullet.js"}},
          {"/websocket", :bullet_handler, [handler: Systemex.WebsocketHandler]}
      ]}
    ]

    {:ok, _} = :cowboy.start_http(
      :http,
      100,
      [port: 4000],
      [env: [dispatch: dispatch]]
    )

    children = [
      worker(Systemex.Connections, []),
      worker(Systemex.CPU, []),
      worker(Systemex.Mem, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Systemex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
