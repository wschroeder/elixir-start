defmodule HealthzTest do
  use ExUnit.Case

  setup_all do
    container_name = "{{ELIXIR_PROJECT_NAME}}-project-#{:rand.uniform(1000000)}"
    {_, 0} = System.cmd "docker", ~w[run -d -t --network {{ELIXIR_PROJECT_NAME}}-uats --name] ++ [container_name] ++ ~w[{{ELIXIR_PROJECT_NAME}}-project]

    on_exit fn ->
      System.cmd "docker", ["rm", "-f", container_name]
    end

    [container_name: container_name]
  end

  test "ping works", context do
    test_healthz_endpoint "ping", ~s["pong"], context
  end

  test "liveness works", context do
    test_healthz_endpoint "liveness", ~s["alive"], context
  end

  test "readiness works", context do
    test_healthz_endpoint "readiness", ~s["ready"], context
  end

  defp test_healthz_endpoint(url, expected_body, context) do
    {status, response} = [0]
                         |> Stream.concat(Stream.interval(1000))
                         |> Stream.take(10)
                         |> Stream.map(fn (_) -> HTTPoison.get "http://#{context.container_name}/healthz/#{url}" end)
                         |> Stream.drop_while(fn ({:ok, _response}) -> false; (_) -> true end)
                         |> Enum.at(0)

    assert status == :ok
    assert response.status_code == 200
    assert response.body == expected_body
  end
end
