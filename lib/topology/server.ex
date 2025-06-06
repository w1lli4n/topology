defmodule Topology.Server do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def job do
    GenServer.call(__MODULE__, :job)
  end

  def print_state do
    GenServer.cast(___MODULE__, :print_state)
  end

  @impl true
  def init(_opts) do
    {:ok, %{active_tasks: [], completed_tasks: []}}
  end

  @impl true
  def handle_call(:job, _from, state) do
    nodes = Node.list()
    n = hd(nodes)

    task =
      {Topology.TaskSupervisor, n}
      |> Task.Supervisor.async_nolink(Topology.Worker, :run, [])

    {:reply, :ok, %{state | active_tasks: [task | state.active_tasks]}}
  end

  @impl true
  def handle_cast(:print_state, _from, state) do
    IO.inspect(state)
    {:noreply, state}
  end

  @impl true
  def handle_info({ref, {:job, msg}}, state) do
    IO.puts(msg)

    {matched_tasks, remaining_tasks} =
      Enum.split_with(state.active_tasks, fn %Task{ref: task_ref} -> task_ref == ref end)

    new_state =
      case matched_tasks do
        [completed_task] ->
          %{
            state
            | active_tasks: remaining_tasks,
              completed_tasks: [completed_task | state.completed_tasks]
          }

        [] ->
          state
      end

    {:noreply, new_state}
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
