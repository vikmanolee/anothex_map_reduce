defmodule Partition do
  def start_link do
    # no need for a Task probably 
    Task.start_link(fn -> loop([], []) end)
  end

  defp loop(processes, values) do
    {:message_queue_len, mailbox_length} = Process.info(self(), :message_queue_len)

    if mailbox_length == 0 do
      values
      # blocking call
      |> Keyword.drop([String.to_atom(~s(\s)), String.to_atom("")])
      |> mapper_check(processes)
    end

    receive do
      {:process_put, caller} ->
        loop([caller | processes], values)

      {:value_put, token} ->
        loop(processes, [{String.to_atom(token), 1} | values])

      other_msg ->
        IO.puts(:stderr, "Partition received: #{IO.inspect(other_msg)}")
    end
  end

  defp mapper_check(values, processes) do
    live_processes = processes |> Enum.filter(&Process.alive?/1) |> Kernel.length()

    # also sync call to count all
    unique_values = values |> Keyword.keys() |> Enum.uniq()

    if live_processes == 0 && length(unique_values) != 0 do
      {:ok, output_writer} = OutputWriter.start_link()

      Enum.each(unique_values, fn unique ->
        spawn(fn ->
          values
          # another sync call to all values
          |> Keyword.take([unique])
          |> Reducer.reduce(output_writer)
        end)
      end)
    end
  end
end
