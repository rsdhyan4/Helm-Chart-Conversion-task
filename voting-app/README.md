# Voting App Helm Chart

A production-ready Helm chart for deploying the example voting application to Kubernetes. This chart demonstrates Helm best practices including proper templating, environment-aware configurations, and comprehensive scalability options.

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Chart Structure & Best Practices](#chart-structure--best-practices)
- [Environment Awareness](#environment-awareness)
- [Scalability Features](#scalability-features)
- [Installation](#installation)
- [Configuration](#configuration)
- [Environment Differences](#environment-differences)
- [Upgrading & Maintenance](#upgrading--maintenance)
- [Troubleshooting](#troubleshooting)

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- kubectl configured to access your cluster
- (Optional) metrics-server for Horizontal Pod Autoscaling

## Chart Structure & Best Practices

This Helm chart follows industry best practices and Helm's recommended structure:

### 📁 Directory Structure

```
voting-app/
├── Chart.yaml              # Chart metadata and versioning
├── values.yaml             # Default configuration values
├── .helmignore            # Files to exclude from packaging
├── README.md              # This documentation
└── templates/              # Kubernetes manifest templates
    ├── _helpers.tpl       # Reusable template functions
    ├── vote-deployment.yaml
    ├── vote-service.yaml
    ├── vote-hpa.yaml      # Horizontal Pod Autoscaler
    ├── result-deployment.yaml
    ├── result-service.yaml
    ├── result-hpa.yaml
    ├── worker-deployment.yaml
    ├── worker-hpa.yaml
    ├── db-deployment.yaml
    ├── db-service.yaml
    ├── db-pvc.yaml         # Persistent Volume Claim
    ├── redis-deployment.yaml
    ├── redis-service.yaml
    └── redis-pvc.yaml
```

### ✅ Best Practices Implemented

1. **Separation of Concerns**: Each Kubernetes resource has its own template file
2. **Template Helpers**: Reusable functions in `_helpers.tpl` for labels, naming, and image configuration
3. **Conditional Rendering**: Components can be enabled/disabled via `enabled` flags
4. **DRY Principle**: No code duplication - shared logic in helpers
5. **Proper Labeling**: Standard Kubernetes labels for resource management
6. **Health Checks**: Liveness and readiness probes for all services
7. **Resource Management**: CPU and memory limits/requests for all containers
8. **Version Control**: Chart versioning in Chart.yaml
9. **Documentation**: Comprehensive README and inline comments

### 🔧 Template Helpers

The `_helpers.tpl` file provides reusable template functions:

- **Naming**: Consistent resource naming across all templates
- **Labels**: Standard Kubernetes labels (app.kubernetes.io/*)
- **Image Configuration**: Centralized image registry and pull policy handling
- **Service Names**: Configurable service names for app compatibility

This eliminates duplication and ensures consistency across all resources.

## Environment Awareness

This chart implements **environment-aware configuration** - a critical best practice for managing applications across different deployment stages.

### How It Works

The chart uses a two-tier configuration system:

1. **Base Configuration** (`values.yaml`): Default values for all environments
2. **Environment Overrides** (`values.yaml` → `environments`): Environment-specific values that override base settings

### Configuration Flow

```
Base Values (values.yaml)
    ↓
Environment Selection (environment: dev/staging/prod)
    ↓
Environment-Specific Overrides (environments.dev/staging/prod)
    ↓
Final Rendered Templates
```

### Why Environment Awareness Matters

1. **Consistency**: Same chart, different configurations - no code duplication
2. **Safety**: Production settings can't accidentally be used in dev
3. **Efficiency**: Dev uses minimal resources, prod gets what it needs
4. **Maintainability**: Change once in values.yaml, applies to all environments
5. **Compliance**: Ensures proper resource allocation per environment

### Environment Configuration

Set the environment to automatically apply pre-configured settings:

```yaml
environment: dev  # Options: dev, staging, prod
```

When you set `environment`, the chart automatically:
- Overrides replica counts
- Adjusts resource limits/requests
- Enables/disables persistence
- Configures autoscaling
- Sets appropriate storage sizes

## Scalability Features

This chart provides comprehensive scalability options at multiple levels:

### 1. Manual Scaling (Replicas)

Configure the number of pod replicas for each component:

```yaml
vote:
  replicas: 1  # Base value
```

Environment-specific overrides:
- **Dev**: 1 replica (cost-effective)
- **Staging**: 2 replicas (testing under load)
- **Prod**: 3+ replicas (high availability)

### 2. Automatic Scaling (HPA)

Horizontal Pod Autoscaler automatically scales based on metrics:

```yaml
vote:
  autoscaling:
    enabled: true
    minReplicas: 3
    maxReplicas: 10
    targetCPUUtilizationPercentage: 80
    targetMemoryUtilizationPercentage: 80
```

**Benefits:**
- Responds to traffic spikes automatically
- Reduces costs during low traffic
- Maintains performance under load
- Prevents resource exhaustion

### 3. Resource Allocation

Fine-tune CPU and memory for each component:

```yaml
vote:
  resources:
    limits:
      cpu: 500m      # Maximum allowed
      memory: 512Mi
    requests:
      cpu: 200m      # Guaranteed minimum
      memory: 256Mi
```

**Why It Matters:**
- **Requests**: Guaranteed resources (scheduling)
- **Limits**: Prevents resource exhaustion (stability)
- **Environment-Specific**: Dev uses less, prod uses more

### 4. Vertical Scaling (Resources)

Resources automatically scale with environment:

| Environment | CPU Limit | Memory Limit | Why |
|------------|-----------|--------------|-----|
| **Dev** | 100m | 128Mi | Minimal for development |
| **Staging** | 200m | 256Mi | Realistic testing |
| **Prod** | 500m | 512Mi | Production workload |

### 5. Storage Scaling

Persistent storage scales with environment needs:

| Environment | DB Storage | Redis Storage | Why |
|------------|------------|---------------|-----|
| **Dev** | emptyDir | emptyDir | No persistence needed |
| **Staging** | 20Gi | 2Gi | Test with persistence |
| **Prod** | 50Gi | 5Gi | Production data volume |

## Configuration

The chart supports extensive configuration through `values.yaml`. Key areas:

### Environment Variables

Configure application settings:

```yaml
vote:
  env:
    OPTION_A: "Cats"
    OPTION_B: "Dogs"
```

### Persistence

Configure persistent storage:

```yaml
db:
  persistence:
    enabled: true
    size: 50Gi
    storageClass: ""  # Uses default storage class
```

### Service Configuration

Customize service types and ports:

```yaml
vote:
  service:
    type: NodePort
    port: 8080
    targetPort: 80
    nodePort: 31000
```

## Service Names

The chart uses simple service names (`db`, `redis`, `vote`, `result`) by default to match the hardcoded service names in the application code. You can override these in `values.yaml`:

```yaml
serviceNames:
  vote: "custom-vote-name"
  result: "custom-result-name"
  db: "db"  # Must be "db" for app compatibility
  redis: "redis"  # Must be "redis" for app compatibility
```

## Installation

### Prerequisites Check

Before installation, verify your environment:

```bash
# Check Kubernetes access
kubectl cluster-info

# Check Helm version
helm version

# Verify chart is valid
helm lint ./voting-app
```

### Development Environment

**Purpose**: Local development and testing with minimal resource usage.

**Characteristics**:
- Single replica per service (cost-effective)
- Minimal resources (100m CPU, 128Mi RAM)
- No persistence (uses emptyDir - data lost on restart)
- No autoscaling
- Fast startup times

**Installation**:

```bash
# Create namespace
kubectl create namespace dev

# Install with dev environment
helm install voting-app-dev ./voting-app \
  --namespace dev \
  --set environment=dev

# Wait for pods to be ready
kubectl wait --for=condition=ready pod \
  -l app.kubernetes.io/instance=voting-app-dev \
  -n dev \
  --timeout=300s

# Verify deployment
kubectl get all -n dev
```

**Why Dev Configuration**:
- **Low Cost**: Minimal resources reduce local machine load
- **Fast Iteration**: Quick restarts without waiting for PVCs
- **Simple**: No complex autoscaling or persistence to manage
- **Safe**: Can't accidentally impact production-like resources

**Access Dev Environment**:

```bash
# Using port-forward (for local access)
kubectl port-forward -n dev svc/voting-app-dev-vote 8080:8080 &
kubectl port-forward -n dev svc/voting-app-dev-result 8081:8081 &

# Access at http://localhost:8080 and http://localhost:8081
```

**Note**: For production clusters, use LoadBalancer or Ingress instead of port-forward.

### Staging Environment

**Purpose**: Pre-production testing with production-like configuration.

**Characteristics**:
- 2 replicas per service (high availability testing)
- Medium resources (200m CPU, 256Mi RAM)
- Persistence enabled (20Gi DB, 2Gi Redis)
- Autoscaling enabled (2-5 replicas)
- Production-like behavior

**Installation**:

```bash
# Create namespace
kubectl create namespace staging

# Install with staging environment
helm install voting-app-staging ./voting-app \
  --namespace staging \
  --set environment=staging

# Wait for pods to be ready
kubectl wait --for=condition=ready pod \
  -l app.kubernetes.io/instance=voting-app-staging \
  -n staging \
  --timeout=300s

# Verify deployment
kubectl get all -n staging
kubectl get hpa -n staging  # Should show HPA resources
kubectl get pvc -n staging  # Should show persistent volumes
```

**Why Staging Configuration**:
- **Realistic Testing**: Tests how app behaves with production-like settings
- **Load Testing**: Multiple replicas allow testing under load
- **Persistence Testing**: Verifies data persistence works correctly
- **Autoscaling Validation**: Ensures HPA works before production
- **Safe Failure**: Can fail without impacting production

**Access Staging Environment**:

```bash
# Using port-forward (for local access)
kubectl port-forward -n staging svc/voting-app-staging-vote 8080:8080 &
kubectl port-forward -n staging svc/voting-app-staging-result 8081:8081 &

# Or get service details for LoadBalancer/Ingress
kubectl get svc -n staging
```

**Note**: For production clusters, configure LoadBalancer or Ingress for external access.

### Production Environment

**Purpose**: Production deployment with maximum reliability and performance.

**Characteristics**:
- 3+ replicas per service (high availability)
- High resources (500m CPU, 512Mi RAM)
- Persistence enabled (50Gi DB, 5Gi Redis)
- Autoscaling enabled (3-10 replicas)
- Production-grade configuration

**Installation**:

```bash
# Create namespace
kubectl create namespace production

# Install with production environment
helm install voting-app-prod ./voting-app \
  --namespace production \
  --set environment=prod

# Wait for pods to be ready
kubectl wait --for=condition=ready pod \
  -l app.kubernetes.io/instance=voting-app-prod \
  -n production \
  --timeout=300s

# Verify deployment
kubectl get all -n production
kubectl get hpa -n production
kubectl get pvc -n production

# Verify resource allocation
kubectl describe pod -l app=vote -n production | grep -A 5 "Limits\|Requests"
```

**Why Production Configuration**:
- **High Availability**: Multiple replicas prevent single point of failure
- **Performance**: Higher resources handle production workloads
- **Data Safety**: Persistent storage ensures data survives pod restarts
- **Auto-Scaling**: Automatically handles traffic spikes
- **Reliability**: Production-grade resource limits prevent resource exhaustion

**Access Production Environment**:

```bash
# Get service details
kubectl get svc -n production

# For LoadBalancer services, get external IP
kubectl get svc voting-app-prod-vote -n production -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

# For Ingress, get ingress hostname
kubectl get ingress -n production

# Using port-forward (for testing only, not recommended for production)
kubectl port-forward -n production svc/voting-app-prod-vote 8080:8080
```

**Note**: Production should use LoadBalancer or Ingress for proper external access, not port-forward or NodePort.

## Environment Differences

### Side-by-Side Comparison

| Feature | Dev | Staging | Production | Why Different |
|---------|-----|---------|------------|--------------|
| **Replicas** | 1 | 2 | 3+ | Dev: cost, Staging: testing, Prod: HA |
| **CPU Limit** | 100m | 200m | 500m | Resource needs scale with environment |
| **Memory Limit** | 128Mi | 256Mi | 512Mi | Production handles more concurrent users |
| **Persistence** | ❌ emptyDir | ✅ 20Gi | ✅ 50Gi | Dev doesn't need data persistence |
| **Autoscaling** | ❌ | ✅ (2-5) | ✅ (3-10) | Dev is static, others need elasticity |
| **Startup Time** | Fast | Medium | Slower | More resources = more initialization |
| **Cost** | Low | Medium | High | Resources directly correlate to cost |
| **Use Case** | Development | Testing | Live Users | Each serves different purpose |

### Why These Differences Matter

1. **Cost Optimization**
   - Dev uses minimal resources → Lower cloud costs
   - Production uses what's needed → Performance without waste

2. **Development Speed**
   - Dev: Fast restarts, no PVC provisioning delays
   - Staging/Prod: Proper persistence for realistic testing

3. **Reliability**
   - Dev: Single replica is fine for development
   - Production: Multiple replicas ensure uptime

4. **Testing Realism**
   - Staging mirrors production → Catch issues before production
   - Dev is simplified → Focus on code, not infrastructure

5. **Resource Management**
   - Each environment gets appropriate resources
   - Prevents resource contention between environments

## Upgrading & Maintenance

### Upgrade a Release

Upgrades should be performed within the same environment and namespace. Here are common upgrade scenarios:

```bash
# Upgrade dev environment with new chart version
helm upgrade voting-app-dev ./voting-app \
  --namespace dev \
  --set environment=dev

# Upgrade with custom values (e.g., increase replicas)
helm upgrade voting-app-dev ./voting-app \
  --namespace dev \
  --set environment=dev \
  --set vote.replicas=2

# Upgrade with values file
helm upgrade voting-app-dev ./voting-app \
  --namespace dev \
  --set environment=dev \
  -f custom-dev-values.yaml

# Upgrade staging environment
helm upgrade voting-app-staging ./voting-app \
  --namespace staging \
  --set environment=staging

# Upgrade production environment
helm upgrade voting-app-prod ./voting-app \
  --namespace production \
  --set environment=prod
```

**Note**: Each environment should remain in its own namespace. To deploy to a different environment, create a new release in the appropriate namespace rather than upgrading an existing one.

### View Release History

```bash
helm history voting-app-dev -n dev
```

### Rollback

```bash
# Rollback to previous version
helm rollback voting-app-dev -n dev

# Rollback to specific revision
helm rollback voting-app-dev 2 -n dev
```

### Uninstallation

```bash
# Uninstall a release
helm uninstall voting-app-dev -n dev

# Clean up namespace (optional)
kubectl delete namespace dev
```

## Accessing the Application

### Using Port-Forward (For Local Testing)

```bash
# Vote service
kubectl port-forward -n <namespace> svc/voting-app-<env>-vote 8080:8080

# Result service
kubectl port-forward -n <namespace> svc/voting-app-<env>-result 8081:8081

# Access at http://localhost:8080 and http://localhost:8081
```

### Using LoadBalancer (Production)

If services are configured with `type: LoadBalancer`:

```bash
# Get external IP
kubectl get svc voting-app-<env>-vote -n <namespace>

# Access using the EXTERNAL-IP shown in the output
```

### Using Ingress (Recommended for Production)

If Ingress is configured:

```bash
# Get ingress hostname
kubectl get ingress -n <namespace>

# Access using the hostname from ingress rules
```

### Using NodePort (If Configured)

```bash
# Get NodePort
VOTE_PORT=$(kubectl get svc voting-app-<env>-vote -n <namespace> -o jsonpath='{.spec.ports[0].nodePort}')

# Access using any node IP and the NodePort
# Note: Get node IPs with: kubectl get nodes -o wide
```

**Note**: The default service type is `NodePort`. For production, consider using `LoadBalancer` or `Ingress` for better access control and routing.

## Troubleshooting

### Check Deployment Status

```bash
# Check Helm release status
helm status voting-app-dev -n dev

# Check all resources
kubectl get all -n <namespace>

# Check pod status
kubectl get pods -n <namespace>
kubectl describe pod <pod-name> -n <namespace>
```

### View Rendered Templates

```bash
# See what Helm will deploy (dry-run)
helm template voting-app-dev ./voting-app \
  --namespace dev \
  --set environment=dev

# Debug with values
helm install voting-app-dev ./voting-app \
  --namespace dev \
  --set environment=dev \
  --debug --dry-run
```

### View Logs

```bash
# Application logs
kubectl logs -l app=vote -n <namespace>
kubectl logs -l app=worker -n <namespace>
kubectl logs -l app=result -n <namespace>

# Follow logs in real-time
kubectl logs -l app=vote -n <namespace> -f
```

### Common Issues

#### Pods Not Starting

```bash
# Check pod events
kubectl describe pod <pod-name> -n <namespace>

# Check resource constraints
kubectl top pods -n <namespace>

# Check if resources are available
kubectl describe nodes
```

#### Services Not Accessible

```bash
# Check service endpoints
kubectl get endpoints -n <namespace>

# Test from inside cluster
kubectl run test-pod --image=curlimages/curl -it --rm \
  --restart=Never -- curl http://<service-name>.<namespace>.svc.cluster.local
```

#### HPA Not Working

```bash
# Check if metrics-server is installed
kubectl get deployment metrics-server -n kube-system

# Check HPA status
kubectl describe hpa <hpa-name> -n <namespace>

# Install metrics-server (if missing)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

#### Persistence Issues

```bash
# Check PVC status
kubectl get pvc -n <namespace>
kubectl describe pvc <pvc-name> -n <namespace>

# Check storage class
kubectl get storageclass

# Check PV
kubectl get pv
```

## Values Reference

See `values.yaml` for a complete list of configurable parameters. Key sections:

- **Global**: Image registry, pull policies
- **Component Configs**: vote, result, worker, db, redis
- **Environments**: dev, staging, prod overrides
- **Service Names**: Customizable service names
- **Resources**: CPU/memory limits and requests
- **Autoscaling**: HPA configuration
- **Persistence**: Storage configuration

## Examples

### Development with Custom Values

```bash
helm install voting-app-dev ./voting-app \
  --namespace dev \
  --set environment=dev \
  --set vote.replicas=2 \
  --set vote.resources.limits.cpu=200m
```

### Staging with Custom Image

```bash
helm install voting-app-staging ./voting-app \
  --namespace staging \
  --set environment=staging \
  --set global.imageRegistry=my-registry.io \
  --set vote.image.repository=my-registry.io/vote-app
```

### Production with Overrides

```bash
helm install voting-app-prod ./voting-app \
  --namespace production \
  --set environment=prod \
  --set db.persistence.size=100Gi \
  --set vote.autoscaling.maxReplicas=20
```

## Notes

- **Service Names**: The application expects service names `db` and `redis` to be available. These are set by default in the chart via `serviceNames` configuration.
- **Storage Classes**: For production, ensure you configure appropriate storage classes for persistent volumes based on your cluster setup.
- **Metrics Server**: Horizontal Pod Autoscaler requires metrics-server to be installed in your cluster. Most managed Kubernetes services include this by default.
- **Namespace Isolation**: Each environment should be deployed to separate namespaces for proper isolation.
- **Resource Limits**: Always set appropriate resource limits to prevent resource exhaustion and ensure fair scheduling.

## Contributing

This chart was created as part of a Helm conversion task, demonstrating:
- Conversion of static Kubernetes YAML to parameterized Helm templates
- Implementation of Helm best practices
- Environment-aware configuration
- Comprehensive scalability options

## License

See the main project repository for license information.

