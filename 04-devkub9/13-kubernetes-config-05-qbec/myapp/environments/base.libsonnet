
// this file has the baseline default parameters
{
  components: {
    backend: {
      replicaCount: 1,
      dbUrl: 'postgresql://postgres:postgres@postgres-headless-svc/news',
    },
    frontend: {
      replicaCount: 1,
      backendUrl: 'backend:9000',
    },
  },
}
