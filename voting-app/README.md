# Voting App Helm Chart

A Helm chart for deploying the example voting application to Kubernetes.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- kubectl configured to access your cluster

## Installation

### Install with default values (dev environment)

```bash
helm install voting-app ./helm-chart/voting-app
```

### Install with custom values

```bash
helm install voting-app ./helm-chart/voting-app -f my-values.yaml
```

### Install for production environment

```bash
helm install voting-app ./helm-chart/voting-app --set environment=prod
```

## Configuration

The chart supports extensive configuration through `values.yaml`. Key configuration areas:

### Environment Configuration

Set the environment to automatically apply environment-specific configurations:

```yaml
environment: dev  # Options: dev, staging, prod
```

### Scalability

Configure replicas and autoscaling for each component:

```yaml
vote:
  replicas: 1
  autoscaling:
    enabled: false
    minReplicas: 1
    maxReplicas: 5
    targetCPUUtilizationPercentage: 80
```

### Resource Allocation

Set CPU and memory limits/requests:

```yaml
vote:
  resources:
    limits:
      cpu: 200m
      memory: 256Mi
    requests:
      cpu: 100m
      memory: 128Mi
```

### Environment Variables

Configure application settings:

```yaml
vote:
  env:
    OPTION_A: "Cats"
    OPTION_B: "Dogs"
```

### Persistence

Configure persistent storage for database and Redis:

```yaml
db:
  persistence:
    enabled: true
    size: 10Gi
    storageClass: ""
```

## Environment-Specific Configurations

The chart includes pre-configured settings for different environments:

- **dev**: Minimal resources, no persistence, single replica
- **staging**: Medium resources, persistence enabled, 2 replicas with autoscaling
- **prod**: High resources, persistence enabled, 3+ replicas with autoscaling

Environment-specific values override the base values when `environment` is set.

## Service Names

The chart uses simple service names (`db`, `redis`, `vote`, `result`) by default to match the hardcoded service names in the application code. You can override these in `values.yaml`:

```yaml
serviceNames:
  vote: "custom-vote-name"
  result: "custom-result-name"
  db: "db"  # Must be "db" for app compatibility
  redis: "redis"  # Must be "redis" for app compatibility
```

## Accessing the Application

After installation, get the service URLs:

```bash
# Get minikube IP
MINIKUBE_IP=$(minikube ip)

# Vote service (NodePort 31000)
echo "Vote: http://${MINIKUBE_IP}:31000"

# Result service (NodePort 31001)
echo "Result: http://${MINIKUBE_IP}:31001"
```

Or use minikube service:

```bash
minikube service voting-app-vote
minikube service voting-app-result
```

## Upgrading

```bash
helm upgrade voting-app ./helm-chart/voting-app
```

## Uninstallation

```bash
helm uninstall voting-app
```

## Chart Structure

```
voting-app/
├── Chart.yaml          # Chart metadata
├── values.yaml         # Default configuration values
├── templates/          # Kubernetes manifest templates
│   ├── _helpers.tpl   # Template helpers
│   ├── vote-*.yaml    # Vote service templates
│   ├── result-*.yaml  # Result service templates
│   ├── worker-*.yaml  # Worker service templates
│   ├── db-*.yaml      # Database templates
│   └── redis-*.yaml   # Redis templates
└── README.md          # This file
```

## Values Reference

See `values.yaml` for a complete list of configurable parameters with descriptions.

## Examples

### Development Deployment

```bash
helm install voting-app-dev ./helm-chart/voting-app \
  --set environment=dev \
  --set vote.replicas=1 \
  --set result.replicas=1
```

### Production Deployment with Custom Resources

```bash
helm install voting-app-prod ./helm-chart/voting-app \
  --set environment=prod \
  --set db.persistence.size=100Gi \
  --set vote.autoscaling.enabled=true \
  --set vote.autoscaling.maxReplicas=10
```

### Staging with Custom Image Registry

```bash
helm install voting-app-staging ./helm-chart/voting-app \
  --set environment=staging \
  --set global.imageRegistry=my-registry.io \
  --set vote.image.repository=my-registry.io/vote-app
```

## Troubleshooting

### Check deployment status

```bash
helm status voting-app
```

### View rendered templates

```bash
helm template voting-app ./helm-chart/voting-app
```

### Debug installation

```bash
helm install voting-app ./helm-chart/voting-app --debug --dry-run
```

### View logs

```bash
kubectl logs -l app=vote
kubectl logs -l app=worker
kubectl logs -l app=result
```

## Notes

- The application expects service names `db` and `redis` to be available. These are set by default in the chart.
- For production, ensure you configure appropriate storage classes for persistent volumes.
- Horizontal Pod Autoscaler requires metrics-server to be installed in your cluster.

