local p = import '../params.libsonnet';
local p_frontend = p.components.frontend;

[
  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: 'frontend',
    },
    spec: {
      ports: [
        {
          name: 'http',
          port: p_frontend.service.port,
          protocol: 'TCP',
          nodePort: p_frontend.service.nodePort,
        },
      ],
      selector: {
        app: 'frontend',
      },
      type: 'NodePort',
    },
  },
  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      labels: {
        app: 'frontend',
      },
      name: 'frontend',
    },
    spec: {
      replicas: p_frontend.replicaCount,
      selector: {
        matchLabels: {
          app: 'frontend',
        },
      },
      template: {
        metadata: {
          labels: {
            app: 'frontend',
          },
        },
        spec: {
          containers: [
            {
              image: 'anguisa/frontend:latest',
              imagePullPolicy: 'IfNotPresent',
              name: 'frontend',
              env: [
                {
                  name: 'BACKEND_HOST',
                  value: p_frontend.backendUrl,
                },
                {
                  name: 'NGINX_ENVSUBST_TEMPLATE_SUFFIX',
                  value: '.conf',
                },
              ],
              volumeMounts: [
                {
                  mountPath: '/static-front',
                  name: 'prod-frontend-volume',
                },
              ],
            },
          ],
          terminationGracePeriodSeconds: 30,
          volumes: [
            {
              name: 'prod-frontend-volume',
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