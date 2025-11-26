# Deployment Guide

This guide explains how to use GitHub Actions for Continuous Deployment of the Helm chart.

## Quick Start

### 1. Setup Kubernetes Secrets

Add your Kubernetes cluster credentials to GitHub Secrets:

```bash
# Get your kubeconfig
cat ~/.kube/config | base64

# Or for a specific context
kubectl config view --flatten --minify | base64
```

Then add to GitHub:
1. Repository → Settings → Secrets and variables → Actions
2. Add secret: `KUBECONFIG_DEV` (paste base64 output)
3. Repeat for `KUBECONFIG_STAGING` and `KUBECONFIG_PROD`

### 2. Deploy Automatically

Add deployment tags to your commit messages:

```bash
# Deploy to dev
git commit -m "feat: new feature [deploy-dev]"
git push

# Deploy to staging
git commit -m "feat: new feature [deploy-staging]"
git push

# Deploy to production
git commit -m "release: v1.0.0 [deploy-prod]"
git push
```

### 3. Deploy Manually

1. Go to **Actions** tab in GitHub
2. Select **"Helm Chart CI/CD"** workflow
3. Click **"Run workflow"**
4. Select:
   - Environment: `dev`, `staging`, or `production`
   - Namespace: `dev`, `staging`, or `production`
   - Release name: `voting-app-dev`, etc.

## Workflow Details

### CI/CD Pipeline

The workflow runs these jobs:

1. **Lint and Test** (always runs)
   - Validates chart structure
   - Tests template rendering for all environments
   - Validates Kubernetes manifests

2. **Deploy to Dev** (conditional)
   - Runs when commit contains `[deploy-dev]`
   - Deploys to `dev` namespace

3. **Deploy to Staging** (conditional)
   - Runs when commit contains `[deploy-staging]`
   - Deploys to `staging` namespace

4. **Deploy to Production** (conditional)
   - Runs when commit contains `[deploy-prod]`
   - Or via manual workflow dispatch
   - Deploys to `production` namespace

### Deployment Process

Each deployment:
1. Creates namespace if it doesn't exist
2. Runs `helm upgrade --install` with appropriate environment
3. Waits for all pods to be ready
4. Verifies deployment status
5. Runs smoke tests (production only)

## Examples

### Example 1: Deploy Feature to Dev

```bash
git add .
git commit -m "feat: add new voting option [deploy-dev]"
git push
```

Workflow will:
- ✅ Lint and test the chart
- ✅ Deploy to dev environment
- ✅ Verify deployment

### Example 2: Promote to Staging

```bash
git commit --allow-empty -m "chore: promote to staging [deploy-staging]"
git push
```

### Example 3: Production Release

```bash
git tag v1.0.0
git commit --allow-empty -m "release: v1.0.0 [deploy-prod]"
git push --tags
```

### Example 4: Manual Production Deployment

1. Go to Actions → "Helm Chart CI/CD"
2. Click "Run workflow"
3. Select:
   - Environment: `production`
   - Namespace: `production`
   - Release name: `voting-app-prod`

## Monitoring Deployments

### View Workflow Status

1. Go to **Actions** tab
2. Click on the workflow run
3. View logs for each job

### Check Deployment

```bash
# After deployment, verify in cluster
kubectl get all -n dev
kubectl get pods -n staging
kubectl get hpa -n production
```

## Troubleshooting

### Workflow Not Triggering

- Check commit message contains deployment tag
- Verify workflow file is in `.github/workflows/`
- Check branch is `main` or `develop`

### Deployment Fails

- Verify kubeconfig secret is correct
- Check cluster connectivity
- Review deployment logs in Actions
- Ensure namespace exists or can be created

### Permission Denied

- Check GitHub Actions permissions
- Verify secrets are set correctly
- Ensure service account has cluster access

## Security Best Practices

1. **Use Environment Protection**: Require approval for production
2. **Limit Secrets Access**: Only grant necessary permissions
3. **Use Service Accounts**: Prefer service accounts over user credentials
4. **Audit Logs**: Regularly review deployment logs
5. **Tag Releases**: Use semantic versioning for releases

## Advanced Configuration

### Custom Values

To deploy with custom values, modify the workflow or use values files:

```yaml
# In workflow, add:
--values custom-values.yaml
```

### Multiple Clusters

For different clusters per environment, use different kubeconfig secrets:
- `KUBECONFIG_DEV` → Dev cluster
- `KUBECONFIG_STAGING` → Staging cluster  
- `KUBECONFIG_PROD` → Production cluster

### Rollback

If deployment fails, Helm automatically rolls back (due to `--atomic` flag).

Manual rollback:
```bash
helm rollback voting-app-prod -n production
```

