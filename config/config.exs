import Config

config :libcluster,
  debug: true,
  topologies: [
    default: [
      strategy: Cluster.Strategy.Gossip
    ]
  ]
