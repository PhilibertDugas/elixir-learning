require Logger

defmodule HTTPSender do
  def send_and_log_request(request) do
    Task.start_link(
      fn ->
        %HTTPotion.Response{status_code: status_code} = HTTPotion.get request
        Logger.info("Request #{request} finished with status code: #{status_code}")
      end
    )
  end
end
