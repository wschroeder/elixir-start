defmodule {{ELIXIR_CLASS}}Web.HealthzController do
  use {{ELIXIR_CLASS}}Web, :controller
  alias {{ELIXIR_CLASS}}.Repo, as: Repo
  alias Ecto.Adapters.SQL, as: SQL

  def ping(conn, _params) do
    render(conn, "ping.json")
  end

  def liveness(conn, _params) do
    render_test_result(conn, test_liveness(), "liveness")
  end

  def readiness(conn, _params) do
    render_test_result(conn, test_liveness(), "readiness")
  end

  defp test_liveness do
    SQL.query(Repo, "select current_timestamp", [])
  end

  defp render_test_result(conn, {:ok, %Mssqlex.Result{}}, test_type) do
    render(conn, "#{test_type}-success.json")
  end

  defp render_test_result(conn, _, test_type) do
    conn
    |> put_status(:service_unavailable)
    |> render("#{test_type}-failure.json")
  end
end
