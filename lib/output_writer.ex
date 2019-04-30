defmodule OutputWriter do
  def start_link do
    Task.start_link(fn -> loop([], []) end)
  end

  defp loop(processes, values) do
    {:message_queue_len, mailbox_length} = Process.info(self(), :message_queue_len)

    if mailbox_length == 0, do: reducer_check(processes, values)

    receive do
      {:process_put, caller} ->
        loop([caller | processes], values)

      {:value_put, value} ->
        loop(processes, [value | values])

      other_msg ->
        IO.puts(:stderr, "OutputWriter received: #{IO.inspect(other_msg)}")
    end
  end

  defp reducer_check(processes, values) do
    live_processes = processes |> Enum.filter(&Process.alive?/1) |> Kernel.length()

    if live_processes == 0 && length(processes) != 0 do
      {:ok, file} = File.open(Path.join("test", "output.txt"), [:write])

      Enum.each(values, fn value ->
        IO.puts(value)
        IO.write(file, "value\n")
      end)

      File.close(file)
      Process.exit(self(), :kill)
    end
  end
end
