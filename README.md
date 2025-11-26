# Voting App Helm Chart

A production-ready Helm chart for deploying the example voting application to Kubernetes.

## 📋 Overview

This Helm chart provides a complete, parameterized deployment solution for the voting application with support for multiple environments (dev, staging, production).

## ✨ Features

- ✅ **Proper Chart Structure**: Follows Helm best practices
- ✅ **Fully Templated**: All Kubernetes resources are parameterized
- ✅ **Scalable**: Configurable replicas, resources, and autoscaling
- ✅ **Environment-Aware**: Pre-configured dev/staging/prod profiles
- ✅ **Production-Ready**: Includes health checks, resource limits, and persistence options

## 📁 Chart Structure

```
helm-chart/
└── voting-app/
    ├── Chart.yaml              # Chart metadata
    ├── values.yaml             # Default configuration
    ├── README.md               # Chart documentation
    ├── .helmignore             # Files to ignore
    └── templates/              # Kubernetes templates
        ├── _helpers.tpl        # Template helpers
        ├── vote-*.yaml         # Vote service templates
        ├── result-*.yaml      # Result service templates
        ├── worker-*.yaml      # Worker templates
        ├── db-*.yaml          # Database templates
        └── redis-*.yaml       # Redis templates
```

## 🚀 Quick Start

### Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- kubectl configured

### Quick Installation

```bash
# Add this chart (if using as a repo)
helm repo add voting-app ./helm-chart/voting-app

# Install for development
helm install voting-app ./voting-app --namespace dev --create-namespace --set environment=dev

# Install for production
helm install voting-app ./voting-app --namespace production --create-namespace --set environment=prod
```

## 📖 Documentation

See the [chart README](./voting-app/README.md) for detailed documentation including:
- Configuration options
- Environment-specific settings
- Installation and usage instructions
- Troubleshooting guide

## 🔧 Configuration

The chart supports extensive configuration through `values.yaml`:

- **Scalability**: Replicas, HPA, resource allocation
- **Configuration**: Environment variables, feature toggles
- **Environments**: Dev, staging, production profiles

## 📝 Requirements

| Component | Version |
|-----------|---------|
| Kubernetes | >= 1.19 |
| Helm | >= 3.0 |

