defmodule {{ELIXIR_CLASS}}Web.HealthzView do
  use {{ELIXIR_CLASS}}Web, :view

  def render("ping.json", _params) do
    "pong"
  end

  def render("liveness-success.json", _params) do
    "alive"
  end

  def render("liveness-failure.json", _params) do
    "not live"
  end

  def render("readiness-success.json", _params) do
    "ready"
  end

  def render("readiness-failure.json", _params) do
    "not ready"
  end
end
