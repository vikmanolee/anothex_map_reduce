defmodule Reducer do
  def reduce(tuples, output_writer) do
    send(output_writer, {:process_put, self()})

    case tuples do
      [] ->
        IO.puts(:stderr, "Empty list")

      [{key, 1} | _] = tuples ->
        num_of_occurencies = Enum.reduce(tuples, 0, fn {_, v}, total -> v + total end)
        send(output_writer, {:value_put, "#{key} #{num_of_occurencies}"})
    end
  end
end
