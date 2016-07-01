defmodule Multithread do
  def send_request(pid, request) do
    HTTPotion.get request, [stream_to: pid]
  end

  def receive_messages do
    Task.start_link(fn -> loop end)
  end

  defp loop do
    receive do
      %HTTPotion.AsyncHeaders{status_code: status_code} ->
        IO.puts Integer.to_string(status_code)
        loop
      %HTTPotion.AsyncChunk{chunk: chunk} ->
        IO.puts chunk
        loop
      %HTTPotion.AsyncEnd{} ->
        IO.puts "end"
        loop
    end
  end
end
