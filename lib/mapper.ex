defmodule Mapper do
  def map(line, partition) do
    send(partition, {:process_put, self()})

    line
    |> String.split()
    |> Enum.each(fn token -> send(partition, {:value_put, token}) end)
  end
end
