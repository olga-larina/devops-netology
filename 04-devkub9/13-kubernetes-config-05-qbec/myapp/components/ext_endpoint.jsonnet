local p = import '../params.libsonnet';

[
  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: 'external-svc',
    },
    spec: {
      type: 'ClusterIP',
      clusterIP: 'None',
      ports: [
        {
          name: 'web',
          protocol: 'TCP',
          port: 80,
          targetPort: 80,
        },
      ],
    },
  },
  {
    apiVersion: 'v1',
    kind: 'Endpoints',
    metadata: {
      name: 'external-svc',
    },
    subsets: [
      {
        addresses: [
          {
            ip: '23.22.52.7',
          },
        ],
        ports: [
          {
            port: 80,
            name: 'web',
          },
        ],
      },
    ],
  },
]