# MXCubeWeb Ansible Deployment

## Prerequisites

- Ansible 2.9+
- Access to target VMs via SSH
- Docker installed on target VMs
- GitHub token with `read:packages` scope (for private images)

## Quick Start

### 1. Configure inventory

Edit `inventory.yaml` to add your VMs:

```yaml
mxcube_vms:
  hosts:
    mxcube_vm1:
      ansible_host: your-vm-hostname
      vm_context: "mxcube_vm1"
```

### 2. Run deployment

For public images (no authentication needed):
```bash
cd ansible
./scripts/start.sh
```

For private images (requires authentication):
```bash
export GITHUB_USERNAME="your-github-username"
export GITHUB_TOKEN="ghp_xxxxxxxxxxxx"
cd ansible
ansible-playbook -i inventory.yaml playbooks/deploy_vm.yml
```

## Docker Images

Images are hosted on GitHub Container Registry:
- `ghcr.io/mxcube/flex-server-simulation:20241212`
- `ghcr.io/mxcube/arinax-md:latest`

### If images are private

Create a GitHub token with `read:packages` scope:
1. Go to https://github.com/settings/tokens/new
2. Select scope: `read:packages`
3. Generate and copy the token

Then either:

**Option A: Environment variables**
```bash
export GITHUB_USERNAME="your-username"
export GITHUB_TOKEN="ghp_xxxxx"
ansible-playbook -i inventory.yaml playbooks/deploy_vm.yml
```

**Option B: Ansible variables**
Create `ansible/secrets.yml`:
```yaml
github_username: "your-username"
github_token: "ghp_xxxxx"
```

Then run:
```bash
ansible-playbook -i inventory.yaml playbooks/deploy_vm.yml -e @secrets.yml
```

**Option C: Ansible Vault (most secure)**
```bash
ansible-vault create ansible/vault.yml
```

Add:
```yaml
github_username: "your-username"
github_token: "ghp_xxxxx"
```

Run with:
```bash
ansible-playbook -i inventory.yaml playbooks/deploy_vm.yml -e @vault.yml --ask-vault-pass
```

## Scripts

- `scripts/start.sh` - Deploy to all VMs
- `scripts/stop.sh` - Stop services on all VMs

## Customization

Edit `group_vars/all.yml` (create if needed) to override defaults:

```yaml
install_base_path: "/opt/mxcube"
service_user: "mxcube"
mxcubeweb_version: "develop"
```
