# GitHub Actions Workflows

This directory contains CI/CD workflows for the Helm chart.

## Workflows

### 1. CI/CD Pipeline (`ci-cd.yml`)

Automated testing and deployment pipeline.

#### Features:
- **Lint and Test**: Validates chart structure and renders templates
- **Auto Deploy**: Deploys based on commit messages
- **Manual Deploy**: Manual deployment via workflow dispatch
- **Environment Support**: Dev, Staging, and Production

#### Triggers:

**Automatic Deployment:**
- `[deploy-dev]` in commit message → Deploys to dev
- `[deploy-staging]` in commit message → Deploys to staging  
- `[deploy-prod]` in commit message → Deploys to production

**Manual Deployment:**
- Go to Actions → "Helm Chart CI/CD" → "Run workflow"
- Select environment, namespace, and release name

#### Required Secrets:

Add these secrets in GitHub repository settings:

- `KUBECONFIG_DEV`: Kubernetes config for dev cluster
- `KUBECONFIG_STAGING`: Kubernetes config for staging cluster
- `KUBECONFIG_PROD`: Kubernetes config for production cluster

**How to get kubeconfig:**
```bash
# For local cluster
cat ~/.kube/config | base64

# For remote cluster
kubectl config view --flatten | base64
```

Paste the base64 encoded output as the secret value.

### 2. Release Workflow (`release.yml`)

Packages and releases the Helm chart when a GitHub release is created.

#### Features:
- Packages the chart
- Generates chart index
- Uploads to GitHub release

#### Usage:

1. Create a new release on GitHub
2. Tag it with version (e.g., `v0.2.0`)
3. Workflow automatically packages and uploads the chart

## Setup Instructions

### 1. Add Kubernetes Secrets

1. Go to your GitHub repository
2. Settings → Secrets and variables → Actions
3. Add the following secrets:

```
KUBECONFIG_DEV=<base64-encoded-kubeconfig>
KUBECONFIG_STAGING=<base64-encoded-kubeconfig>
KUBECONFIG_PROD=<base64-encoded-kubeconfig>
```

### 2. Configure Environment Protection (Optional)

For production deployments, you can add environment protection rules:

1. Settings → Environments
2. Create environments: `dev`, `staging`, `production`
3. Add required reviewers for production
4. Add deployment branches (e.g., only `main` for production)

### 3. Test the Workflow

```bash
# Test linting (runs on every push)
git commit --allow-empty -m "test: trigger CI"

# Test dev deployment
git commit --allow-empty -m "feat: new feature [deploy-dev]"

# Test staging deployment
git commit --allow-empty -m "feat: new feature [deploy-staging]"

# Test production deployment
git commit --allow-empty -m "feat: new feature [deploy-prod]"
```

## Deployment Examples

### Automatic Deployment

```bash
# Deploy to dev
git commit -m "fix: bug fix [deploy-dev]"
git push

# Deploy to staging
git commit -m "feat: new feature [deploy-staging]"
git push

# Deploy to production
git commit -m "release: v1.0.0 [deploy-prod]"
git push
```

### Manual Deployment

1. Go to GitHub Actions
2. Select "Helm Chart CI/CD"
3. Click "Run workflow"
4. Fill in:
   - Environment: `dev`, `staging`, or `production`
   - Namespace: `dev`, `staging`, or `production`
   - Release name: `voting-app-dev`, `voting-app-staging`, etc.

## Workflow Status

Check workflow status:
- GitHub → Actions tab
- View logs for each job
- See deployment status

## Troubleshooting

### Workflow Fails at Lint

- Check chart structure
- Run `helm lint ./voting-app` locally
- Fix any errors

### Deployment Fails

- Check Kubernetes cluster connectivity
- Verify kubeconfig secret is correct
- Check namespace exists
- Review deployment logs in Actions

### Permission Issues

- Ensure GitHub Actions has permission to create releases
- Check repository settings → Actions → General
- Verify secrets are correctly set

## Best Practices

1. **Always test locally first**: Run `helm lint` and `helm template` before pushing
2. **Use commit message tags**: `[deploy-dev]`, `[deploy-staging]`, `[deploy-prod]`
3. **Review before production**: Use environment protection rules
4. **Monitor deployments**: Check Actions logs after deployment
5. **Version control**: Tag releases properly for chart versioning

