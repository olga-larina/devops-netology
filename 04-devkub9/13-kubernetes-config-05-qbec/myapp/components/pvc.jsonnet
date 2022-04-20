local p = import '../params.libsonnet';

[
  {
    apiVersion: 'v1',
    kind: 'PersistentVolumeClaim',
    metadata: {
      name: 'prod-pvc',
    },
    spec: {
      storageClassName: 'nfs',
      accessModes: [
        'ReadWriteMany',
      ],
      resources: {
        requests: {
          storage: '1Gi',
        },
      },
    },
  },
]