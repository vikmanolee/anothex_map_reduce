defmodule InputReader do
  @new_line_match ~r/\r|\n|\r\n/

  def reader(file_name, partition) do
    case File.read(file_name) do
      {:ok, body} ->
        do_read(body, partition)

      {:error, reason} ->
        IO.puts(:stderr, "File Error: #{:file.format_error(reason)}")
    end
  end

  defp do_read(body, partition) do
    body
    # blocking sync operation
    |> String.split(@new_line_match, trim: true)
    |> Enum.each(fn line -> spawn(fn -> Mapper.map(line, partition) end) end)
  end
end
