defmodule Topology.Server do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def job do
    GenServer.call(__MODULE__, :job)
  end

  @impl true
  def init(_opts) do
    {:ok, %{}}
  end

  @impl true
  def handle_call(:job, _from, state) do
    nodes = Node.list()
    n = hd(nodes)

    {Topology.TaskSupervisor, n}
    |> Task.Supervisor.async_nolink(Topology.Worker, :run, [])

    {:reply, :ok, state}
  end

  @impl true
  def handle_info({_ref, {:job, msg}}, state) do
    IO.puts(msg)
    {:noreply, state}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, _pid, _reason}, state) do
    # This clause handles the {:DOWN, ...} messages from monitored tasks.
    # _ref: the monitor reference
    # _pid: the PID of the terminated process (the Task)
    # _reason: the reason for termination (:normal, :shutdown, or an error term)

    # You can add logging here if you want to know when a task finishes or crashes:
    # Logger.info("Task process #{inspect(_pid)} terminated with reason: #{inspect(_reason)}")

    # Crucially, return {:noreply, state} to keep the GenServer alive
    {:noreply, state}
  end
end
