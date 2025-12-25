# GitHub Workflow - Project Mother

## Repository Setup

### Create GitHub Repository

```bash
# On GitHub
1. Go to https://github.com/new
2. Repository name: mother
3. Description: "Media server infrastructure for Mother project"
4. Private repository
5. Initialize with README: No (we'll create locally)
6. Add .gitignore: None (we'll create custom)
7. License: None (private repo)
```

### Local Repository Initialization

```bash
# On your WSL
cd /home/alig/projects/mother

# Initialize git
git init

# Create .gitignore
cat > .gitignore << 'EOF'
# Secrets and credentials
.env
*.gpg
*_credentials.yml
users_database.yml
*.pem
*.key
id_rsa*
id_ed25519*

# Application data
configs/*/
!configs/*/README.md
*.db
*.sqlite
*.sqlite3

# Logs
logs/
*.log

# Temporary files
*.tmp
*.bak
*.swp
*~

# OS files
.DS_Store
Thumbs.db

# Backup files
*.tar.gz
*.zip
backups/

# Data directories
downloads/
media/

# Docker
.docker/

# Python
__pycache__/
*.py[cod]
*$py.class
.venv/
venv/
EOF

# Create README.md
cat > README.md << 'EOF'
# Project Mother

Unified media server infrastructure for consolidated media management.

## Overview
Media server running on Ubuntu at Chris's location with real-time sync to Unraid.

## Documentation
- [Project Overview](PROJECT_OVERVIEW.md)
- [Network Setup](NETWORK_SETUP.md)
- [Docker Setup](DOCKER_SETUP.md)
- [Initial Sync](INITIAL_SYNC.md)
- [Sync Strategy](SYNC_STRATEGY.md)
- [Security](SECURITY.md)
- [Tracker Migration](TRACKER_MIGRATION.md)
- [GitHub Workflow](GITHUB_WORKFLOW.md)
- [TODO](TODO.md)
- [Completed](COMPLETED.md)

## Quick Start
See documentation files for detailed setup instructions.

## Security
This repository contains infrastructure code. Secrets are managed via `.env` file which is NOT committed.
EOF

# Create example configs
mkdir -p configs/examples

# Initial commit
git add .
git commit -m "Initial commit: Project Mother infrastructure"

# Add remote
git remote add origin git@github.com:YOUR_USERNAME/mother.git

# Push to GitHub
git branch -M main
git push -u origin main
```

## Repository Structure

```
mother/
├── .github/
│   └── workflows/
│       ├── docker-update.yml
│       ├── backup.yml
│       └── security-scan.yml
├── configs/
│   ├── examples/
│   │   ├── docker-compose.example.yml
│   │   ├── .env.example
│   │   ├── authelia-config.example.yml
│   │   └── recyclarr.example.yml
│   └── README.md
├── scripts/
│   ├── sync/
│   │   ├── generate_inventory.py
│   │   ├── compare_libraries.py
│   │   └── generate_sync_plan.py
│   ├── backup.sh
│   ├── update.sh
│   ├── sync_to_unraid.sh
│   └── deploy.sh
├── docs/
│   ├── PROJECT_OVERVIEW.md
│   ├── NETWORK_SETUP.md
│   ├── DOCKER_SETUP.md
│   ├── INITIAL_SYNC.md
│   ├── SYNC_STRATEGY.md
│   ├── SECURITY.md
│   ├── TRACKER_MIGRATION.md
│   ├── GITHUB_WORKFLOW.md
│   ├── TODO.md
│   └── COMPLETED.md
├── .gitignore
├── .env.example
├── docker-compose.yml (example - actual in configs/)
├── README.md
└── LICENSE (optional)
```

## GitHub Actions Workflows

### 1. Docker Update Workflow

Create `.github/workflows/docker-update.yml`:

```yaml
name: Update Docker Containers

on:
  schedule:
    # Run weekly on Sunday at 2 AM
    - cron: '0 2 * * 0'
  workflow_dispatch: # Manual trigger

jobs:
  update:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Setup SSH
        uses: webfactory/ssh-agent@v0.8.0
        with:
          ssh-private-key: ${{ secrets.MOTHER_SSH_KEY }}

      - name: Pull latest images and restart
        run: |
          ssh -o StrictHostKeyChecking=no user@10.0.1.10 << 'EOF'
            cd /opt/mother
            docker-compose pull
            docker-compose up -d
            docker image prune -f
          EOF

      - name: Verify services
        run: |
          ssh user@10.0.1.10 << 'EOF'
            cd /opt/mother
            docker-compose ps
            docker-compose logs --tail=20
          EOF

      - name: Send notification
        if: always()
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          text: Docker containers updated on Mother server
          webhook_url: ${{ secrets.SLACK_WEBHOOK_URL }}
        # Or use Discord, Telegram, etc.
```

### 2. Backup Workflow

Create `.github/workflows/backup.yml`:

```yaml
name: Backup Configurations

on:
  schedule:
    # Daily at 3 AM
    - cron: '0 3 * * *'
  workflow_dispatch:

jobs:
  backup:
    runs-on: ubuntu-latest
    steps:
      - name: Setup SSH
        uses: webfactory/ssh-agent@v0.8.0
        with:
          ssh-private-key: ${{ secrets.MOTHER_SSH_KEY }}

      - name: Create backup
        run: |
          ssh user@10.0.1.10 << 'EOF'
            /opt/mother/scripts/backup.sh
          EOF

      - name: Download backup
        run: |
          scp user@10.0.1.10:/backups/latest-backup.tar.gz.gpg ./backup.tar.gz.gpg

      - name: Upload to GitHub
        uses: actions/upload-artifact@v3
        with:
          name: mother-backup-${{ github.run_number }}
          path: backup.tar.gz.gpg
          retention-days: 30

      - name: Upload to cloud storage (optional)
        # Add S3, Backblaze B2, etc. upload here
        run: echo "Upload to cloud storage"
```

### 3. Security Scan Workflow

Create `.github/workflows/security-scan.yml`:

```yaml
name: Security Scan

on:
  schedule:
    # Weekly on Monday at 1 AM
    - cron: '0 1 * * 1'
  workflow_dispatch:

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Run Trivy scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'config'
          scan-ref: '.'
          format: 'sarif'
          output: 'trivy-results.sarif'

      - name: Upload Trivy results to GitHub Security
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'

      - name: SSH Security Scan
        uses: webfactory/ssh-agent@v0.8.0
        with:
          ssh-private-key: ${{ secrets.MOTHER_SSH_KEY }}

      - name: Run Lynis audit
        run: |
          ssh user@10.0.1.10 << 'EOF'
            sudo lynis audit system --quick
          EOF
```

## GitHub Secrets Configuration

### Add Secrets to GitHub

1. Go to repository → Settings → Secrets and variables → Actions
2. Add the following secrets:

```
MOTHER_SSH_KEY          - Private SSH key for Mother server
SLACK_WEBHOOK_URL       - Slack webhook for notifications (optional)
DISCORD_WEBHOOK_URL     - Discord webhook (optional)
UNRAID_SSH_KEY          - SSH key for Unraid (if needed)
GPG_PASSPHRASE          - Passphrase for encrypted backups
CLOUD_STORAGE_KEY       - API key for cloud backup (if used)
```

### Generate SSH Key for GitHub Actions

```bash
# On your WSL
ssh-keygen -t ed25519 -C "github-actions" -f ~/.ssh/github_actions_ed25519

# Copy public key to Mother server
ssh-copy-id -i ~/.ssh/github_actions_ed25519.pub user@10.0.1.10

# Add private key to GitHub secrets
cat ~/.ssh/github_actions_ed25519
# Copy entire output including -----BEGIN and -----END lines
```

## Deployment Script

Create `scripts/deploy.sh`:

```bash
#!/bin/bash
#
# Deploy Mother infrastructure from GitHub repository
#

set -e

MOTHER_HOST="10.0.1.10"
MOTHER_USER="your_username"
MOTHER_DIR="/opt/mother"
REPO_URL="git@github.com:YOUR_USERNAME/mother.git"

echo "Deploying Mother infrastructure..."

# SSH into Mother and deploy
ssh ${MOTHER_USER}@${MOTHER_HOST} << 'EOF'
  set -e
  
  # Clone or update repository
  if [ -d "/opt/mother/.git" ]; then
    echo "Updating repository..."
    cd /opt/mother
    git pull origin main
  else
    echo "Cloning repository..."
    sudo mkdir -p /opt/mother
    sudo chown -R $USER:$USER /opt/mother
    git clone ${REPO_URL} /opt/mother
  fi
  
  cd /opt/mother
  
  # Create necessary directories
  mkdir -p logs configs/{radarr-hd,radarr-4k,sonarr-hd,sonarr-4k,qbittorrent,recyclarr,nginx,authelia,seerr,jackett,flaresolverr,cross-seed}
  
  # Copy example configs if .env doesn't exist
  if [ ! -f ".env" ]; then
    echo "Creating .env from example..."
    cp .env.example .env
    echo "IMPORTANT: Edit /opt/mother/.env with your actual secrets!"
  fi
  
  # Pull Docker images
  docker-compose pull
  
  # Start services
  docker-compose up -d
  
  echo "Deployment complete!"
  docker-compose ps
EOF

echo "Deployment finished. Check services status."
```

Make executable:
```bash
chmod +x scripts/deploy.sh
```

## Development Workflow

### Local Development (WSL)

```bash
# Make changes locally
cd /home/alig/projects/mother

# Edit files
nano docker-compose.yml

# Test locally (if applicable)
docker-compose config  # Validate syntax

# Commit changes
git add .
git commit -m "feat: Add new service configuration"

# Push to GitHub
git push origin main

# Deploy to Mother (manual)
./scripts/deploy.sh

# Or trigger GitHub Action for deployment
```

### Branch Strategy

```bash
# Main branch: Production
main

# Development branch: Testing
develop

# Feature branches: New features
feature/add-prowlarr
feature/upgrade-authelia
bugfix/qbittorrent-config
```

### Git Workflow

```bash
# Create feature branch
git checkout -b feature/add-monitoring

# Make changes
# ... edit files ...

# Commit
git add .
git commit -m "feat: Add monitoring stack (Prometheus + Grafana)"

# Push to GitHub
git push origin feature/add-monitoring

# Create Pull Request on GitHub
# Review and merge to main

# Deploy to Mother
git checkout main
git pull origin main
./scripts/deploy.sh
```

## Commit Message Convention

Follow Conventional Commits:

```
feat: Add new feature
fix: Fix bug
docs: Update documentation
style: Format code
refactor: Refactor code
test: Add tests
chore: Update dependencies
security: Security improvements
```

Examples:
```bash
git commit -m "feat: Add Prowlarr to replace Jackett"
git commit -m "fix: Correct Radarr-4K port mapping"
git commit -m "docs: Update tracker migration guide"
git commit -m "security: Implement Fail2Ban configuration"
git commit -m "chore: Update Docker images to latest versions"
```

## Version Tagging

```bash
# Tag releases
git tag -a v1.0.0 -m "Initial release"
git push origin v1.0.0

# Semantic versioning
v1.0.0 - Initial stable release
v1.1.0 - Minor feature additions
v1.1.1 - Bug fixes
v2.0.0 - Major changes (breaking)
```

## Backup Repository

### Clone to Multiple Locations

```bash
# Your WSL (primary)
/home/alig/projects/mother

# Unraid (backup)
/mnt/user/backups/repos/mother

# Terminus (backup)
/opt/repos/mother
```

### Automated Sync to Multiple Locations

```bash
# Add to cron
0 4 * * * cd /home/alig/projects/mother && git pull && rsync -av /home/alig/projects/mother/ /mnt/unraid/backups/repos/mother/
```

## CI/CD Pipeline

### Full Deployment Pipeline

```yaml
# .github/workflows/deploy.yml
name: Deploy to Mother

on:
  push:
    branches:
      - main
  workflow_dispatch:

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      
      - name: Validate docker-compose
        run: |
          docker-compose -f configs/examples/docker-compose.example.yml config

  deploy:
    needs: validate
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      
      - name: Setup SSH
        uses: webfactory/ssh-agent@v0.8.0
        with:
          ssh-private-key: ${{ secrets.MOTHER_SSH_KEY }}
      
      - name: Deploy to Mother
        run: |
          ssh user@10.0.1.10 << 'EOF'
            cd /opt/mother
            git pull origin main
            docker-compose pull
            docker-compose up -d
          EOF
      
      - name: Health Check
        run: |
          sleep 30
          ssh user@10.0.1.10 'docker-compose -f /opt/mother/docker-compose.yml ps'
```

## Documentation Sync

### Sync Docs to Repository

```bash
# From WSL, sync to GitHub
cd /home/alig/projects/mother/docs

# Add all documentation
git add *.md

# Commit
git commit -m "docs: Update project documentation"

# Push
git push origin main
```

## Collaboration

### Adding Collaborators

```bash
# GitHub Settings → Collaborators
# Add: Chris Stuttler (chris_github_username)
```

### Code Review Process

1. Create feature branch
2. Make changes
3. Push to GitHub
4. Create Pull Request
5. Request review from collaborator
6. Address feedback
7. Merge to main
8. Deploy

## GitHub Project Board (Optional)

Create Kanban board for task tracking:

```
Columns:
- To Do
- In Progress
- Testing
- Done

Labels:
- enhancement
- bug
- documentation
- security
- infrastructure
```

## Integration with External Services

### Discord/Slack Notifications

```yaml
# Add to any workflow
- name: Send notification
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: 'Workflow completed'
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

### Monitoring Integration

- Uptime Kuma: Monitor GitHub Actions
- Grafana: Visualize deployment metrics
- PagerDuty: Alert on failed deployments

## Next Steps
1. ⏳ Create GitHub repository
2. ⏳ Setup SSH keys for GitHub
3. ⏳ Initialize local repository
4. ⏳ Commit initial code
5. ⏳ Push to GitHub
6. ⏳ Add GitHub secrets
7. ⏳ Create GitHub Actions workflows
8. ⏳ Test deployment script
9. ⏳ Setup branch protection
10. ⏳ Configure notifications
11. ⏳ Add collaborators
12. ⏳ Create project board
