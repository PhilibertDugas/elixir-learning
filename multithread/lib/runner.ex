defmodule Runner do
  def main do
    struct = get_struct
    launch_thread_groups(struct.elt)
  end

  defp get_struct do
    {:ok, content} = Parser.read_test
    Poison.decode!(content, as: %Elt{})
  end

  defp launch_thread_groups([head | tail]) do
    Task.start(fn -> launch_threads(MapHelper.to_struct(ThreadGroup, head)) end)
    launch_thread_groups(tail)
  end

  defp launch_thread_groups([]) do
    IO.puts "Thread groups finished"
  end

  defp launch_threads(group = %ThreadGroup{}) do
    case group.threads do
      0 -> IO.puts "Finished starting threads"
      _ ->
        Task.start fn ->
          launch_request(MapHelper.to_struct(Request, group.requests), group.repetitions)
        end
        launch_threads(%{ group | threads: group.threads - 1 })
    end
  end

  defp launch_request(request = %Request{}, repetition) do
    case repetition do
      0 -> IO.puts "finished sending request"
      _ ->
        HTTPSender.send_and_log_request(request.method, request.url, request.assert)
        launch_request(request, repetition - 1)
    end
  end
end
