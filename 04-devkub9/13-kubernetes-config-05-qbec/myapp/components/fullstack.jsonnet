local p = import '../params.libsonnet';
local p_fullstack = p.components.fullstack;
local p_backend = p.components.backend;
local p_frontend = p.components.frontend;

[
  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: 'fullstack',
    },
    spec: {
      ports: [
        {
          name: 'http',
          port: p_fullstack.service.port,
          protocol: 'TCP',
          nodePort: p_fullstack.service.nodePort,
        },
      ],
      selector: {
        app: 'fullstack',
      },
      type: 'NodePort',
    },
  },
  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      labels: {
        app: 'fullstack',
      },
      name: 'fullstack',
    },
    spec: {
      replicas: p_fullstack.replicaCount,
      selector: {
        matchLabels: {
          app: 'fullstack',
        },
      },
      template: {
        metadata: {
          labels: {
            app: 'fullstack',
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
                  name: 'stage-volume',
                },
              ],
            },
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
                  name: 'stage-volume',
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
              name: 'stage-volume',
              emptyDir: {},
            },
          ],
        },
      },
    },
  },
]