
// this file has the param overrides for the stage environment
local base = import './base.libsonnet';

base {
  components +: {
    fullstack: {
      service: {
        port: 80,
        nodePort: 32183,
      },
      replicaCount: 1,
    },
    frontend +: {
      backendUrl: 'localhost:9000',
    },
  }
}

