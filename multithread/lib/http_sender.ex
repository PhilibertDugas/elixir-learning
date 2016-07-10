defmodule HTTPSender do
  def send_request(request, pid) do
    HTTPotion.get request, [stream_to: pid]
  end

  def receive_requests do
    Task.start_link(fn -> loop end)
  end

  defp loop do
    receive do
      %HTTPotion.AsyncHeaders{status_code: status_code} ->
        IO.puts Integer.to_string(status_code)
        loop
      %HTTPotion.AsyncChunk{chunk: chunk} ->
        IO.puts "Request Chunk Received"
        loop
      %HTTPotion.AsyncEnd{} ->
        IO.puts "end"
        loop
    after
      5_000 -> "No request in 5 seconds"
    end
  end
end
