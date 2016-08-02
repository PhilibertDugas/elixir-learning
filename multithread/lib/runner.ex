defmodule Runner do
  def main do
    struct = get_struct
    launch_thread_groups(struct.elt, [])
  end

  defp get_struct do
    {:ok, content} = Parser.read_test
    Poison.decode!(content, as: %Elt{})
  end

  defp launch_thread_groups([head | tail], tasks) do
    task = Task.async(fn -> launch_threads(MapHelper.to_struct(ThreadGroup, head), []) end)
    launch_thread_groups(tail, List.insert_at(tasks, 0, task))
  end

  defp launch_thread_groups([], tasks) do
    Task.yield_many(tasks, 30000)
    IO.puts "Thread groups finished"
  end

  defp launch_threads(group = %ThreadGroup{}, tasks) do
    case group.threads do
      0 ->
        Task.yield_many(tasks, 30000)
        IO.puts "Finished threads"
      _ ->
        task = Task.async(fn -> launch_request(MapHelper.to_struct(Request, group.requests), group.repetitions) end)
        launch_threads(%{ group | threads: group.threads - 1 }, List.insert_at(tasks, 0, task))
    end
  end

  defp launch_request(request = %Request{}, repetition) do
    case repetition do
      0 ->
        IO.puts "finished sending request"
      _ ->
        HTTPSender.send_and_log_request(request.method, request.url, request.assert)
        launch_request(request, repetition - 1)
    end
  end
end
