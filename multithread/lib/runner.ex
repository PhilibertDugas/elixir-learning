defmodule Runner do
  def main do
    struct = get_struct
    [ thread_group | _ ] = struct.elt
    launch_threads(thread_group)
  end

  defp get_struct do
    {:ok, content} = Parser.read_test
    Poison.decode!(content, as: %Elt{})
  end

  defp launch_threads(param = %{"repetitions" => repetitions, "requests" => requests, "threads" => threads}) do
    case threads do
      0 -> IO.puts "Finished starting threads"
      _ ->
        Task.start fn ->
          {:ok, pid} = HTTPSender.receive_requests
          launch_request(requests, repetitions, pid)
        end
        launch_threads(%{ param | "threads" => threads - 1 })
    end
  end

  defp launch_request(request = %{"url" => url}, repetition, pid) do
    case repetition do
      0 -> IO.puts "finished sending request"
      _ ->
      HTTPSender.send_request(url, pid)
      launch_request(request, repetition - 1, pid)
    end
  end
end
