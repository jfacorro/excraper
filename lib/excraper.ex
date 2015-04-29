defmodule Excraper do
  @website "https://thestrangeloop.com"

  def avg_abstract_length do
    session_links()
    |> pp
    |> Enum.map(fn str -> <<@website, str::binary>> end)
    |> Enum.map(&HTTPoison.get!/1)
    |> Enum.map(&extract_abstract/1)
    |> ps
    |> Enum.map(&count_words/1)
    |> average
    |> pp
  end

  defp session_links do
    response = HTTPoison.get! <<@website, "/archive/2014">>
    response.body
    |> Floki.attribute(".speaker .pic_speaker", "href")
    #|> Enum.take(2)
  end

  defp extract_abstract response do
    f = fn ({_, text}) -> text end
    response.body
    |> Floki.find(".grid_11")
    |> List.first
    |> Tuple.to_list
    |> List.last
    |> Enum.reduce({:accept, ""}, &filter_abstract_p/2)
    |> f.()
  end

  defp filter_abstract_p {"p", _, _} = p, {:accept, acc} do
    text = Floki.text p
    {:accept, <<acc::binary, text::binary>>}
  end
  defp filter_abstract_p {"h4", _, _}, {:accept, acc} do
    {:stop, acc}
  end
  defp filter_abstract_p _, result do
    result
  end

  defp count_words str do
    length(String.split(str, " "))
  end

  defp average numbers do
    Enum.reduce(numbers, 0, &:erlang.+/2) / length(numbers)
  end

  defp pp x do
    :io.format("=== ~p~n", [x])
    x
  end
  defp ps x do
    :io.format("=== ~s~n", [x])
    x
  end
end
