defmodule Funnel.PercolatorPool do
  @moduledoc """
  Pool of `Funnel.Percolators`.
  """
  use Supervisor
  import Funnel.Percolator, only: [percolate: 3]

  @doc """

  Start the percolators's pool
  """
  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    # Here are my pool options
    pool_options = [
      name: {:local, :percolator_pool},
      worker_module: Funnel.Percolator,
      size: 20,
      max_overflow: 40
    ]

    children = [
      :poolboy.child_spec(:percolator_pool, pool_options)
    ]

    supervise(children, strategy: :one_for_one)
  end

  @doc """

  Submit a document to Elasticsearch's percolator through the pool.
  """
  def percolate(index_id, body) do
    :poolboy.transaction(:percolator_pool, fn(percolator)-> percolate(percolator, index_id, body) end)
  end
end
