defmodule Echo do
  # Is this the right approach?
  defmacro __using__(opts) do
    server_port = Keyword.get(opts, :port, 4040)
    connection_handler = Keyword.get(opts, :handler, Echo.Demo.KV)
    packet_type = Keyword.get(opts, :packet, :line)
    pool_size = Keyword.get(opts, :pool_size, 5)

    quote do
      use Supervisor

      def start_link(opts \\ []) do
        Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
      end

      @impl true
      def init(opts) do
        echo_opts = [
          handler: unquote(connection_handler),
          port: unquote(server_port),
          packet: unquote(packet_type),
          pool_size: unquote(pool_size)
        ]

        children = [
          Echo.Controller.supervisor(),
          Echo.Acceptor.supervisor(),
          {Echo.Core, echo_opts}
        ]

        supervisor_opts = Keyword.merge([strategy: :one_for_one], opts)

        Supervisor.init(children, supervisor_opts)
      end
    end
  end
end
