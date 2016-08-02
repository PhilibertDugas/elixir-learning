require Logger

defmodule HTTPSender do
  def send_and_log_request(method, url, assert) do
    atom_method = String.downcase(method) |> String.to_atom
    {time, %HTTPotion.Response{status_code: status_code}} = :timer.tc(fn -> HTTPotion.request(atom_method, url) end)
    log_request(url, status_code, assert, time)
  end

  defp log_request(url, status_code, assert, time) do
    milliseconds_time = time / 1000
    success = assert["status_code"] == status_code
    Logger.info("Request: #{url}, Status Code: #{status_code}, Success: #{success}, Time: #{milliseconds_time}ms")
  end
end
