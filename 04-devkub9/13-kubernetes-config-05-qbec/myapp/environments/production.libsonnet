
// this file has the param overrides for the production environment
local base = import './base.libsonnet';

base {
  components +: {
    backend +: {
      service: {
        port: 9000,
      },
      replicaCount: 3,
    },
    frontend +: {
      service: {
        port: 80,
        nodePort: 32182,
      },
      replicaCount: 3,
      backendUrl: 'backend:9000',
    },
  }
}