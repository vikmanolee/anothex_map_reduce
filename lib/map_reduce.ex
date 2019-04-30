defmodule MapReduce do
  def main(args) do
    args
    |> parse_args()
    |> do_map_reduce()
  end

  defp parse_args(args) do
    {options, _rest, _errors} = OptionParser.parse(args, switches: [file: :string])

    options
  end

  defp do_map_reduce([{:file, file_name}]) do
    {:ok, partition_pid} = Partition.start_link()
    InputReader.reader(file_name, partition_pid)

    forever()
  end

  defp do_map_reduce(_) do
    IO.puts("error: No input file")
  end

  defp forever() do
    forever()
  end
end
