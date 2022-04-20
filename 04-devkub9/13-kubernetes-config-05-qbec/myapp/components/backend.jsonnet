local p = import '../params.libsonnet';
local p_backend = p.components.backend;

[
  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: 'backend',
    },
    spec: {
      ports: [
        {
          name: 'back',
          port: p_backend.service.port,
        },
      ],
      selector: {
        app: 'backend',
      },
      type: 'ClusterIP',
    },
  },
  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      labels: {
        app: 'backend',
      },
      name: 'backend',
    },
    spec: {
      replicas: p_backend.replicaCount,
      selector: {
        matchLabels: {
          app: 'backend',
        },
      },
      template: {
        metadata: {
          labels: {
            app: 'backend',
          },
        },
        spec: {
          containers: [
            {
              image: 'anguisa/backend:latest',
              imagePullPolicy: 'IfNotPresent',
              name: 'backend',
              env: [
                {
                  name: 'DATABASE_URL',
                  value: p_backend.dbUrl,
                },
              ],
              volumeMounts: [
                {
                  mountPath: '/static-back',
                  name: 'prod-backend-volume',
                },
              ],
            },
          ],
          initContainers: [
            {
              name: 'init-backend',
              image: 'busybox:1.28',
              command: [
                'sh',
                '-c',
                'until nslookup postgres-headless-svc; do echo waiting for postgres-headless-svc; sleep 2; done',
              ],
            },
          ],
          terminationGracePeriodSeconds: 30,
          volumes: [
            {
              name: 'prod-backend-volume',
              persistentVolumeClaim: {
                claimName: 'prod-pvc',
              },
            },
          ],
        },
      },
    },
  },
]