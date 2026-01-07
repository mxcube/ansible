# MXCubeWeb Ansible Deployment

Automated deployment of MXCubeWeb on virtual machines.

## Prerequisites

1. **Ansible** installed on your local machine
2. **SSH access** to target VMs
3. **Docker** installed on VMs with docker-compose
4. **Docker images** loaded on VMs (`flex-server:latest` and `arinax:MD`)

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

### 2. Configure variables

Edit `playbooks/group_vars/all.yml` to customize:

```yaml
install_base_path: "/opt/mxcube"    # Installation path
service_user: "mxcube"              # System user
use_local_repos: true               # Use local repos or clone from GitHub
mxcubeweb_version: "develop"        # Git branch
```

### 3. Deploy

```bash
cd ansible
./scripts/start.sh
```

The script will:
- Ask if you want to deploy/update MXCubeWeb
- Start the service if not running
- Create an SSH tunnel to access the web interface

Access MXCubeWeb at: http://localhost:8081

## Prepare VMs (first time only)

On each VM, load Docker images once:

```bash
# Copy tar files to the VM
scp flex-server-simulation_20241212.tar your-vm:/tmp/
scp arinax_md.tar your-vm:/tmp/

# On the VM, load images
ssh your-vm
docker load -i /tmp/flex-server-simulation_20241212.tar
docker load -i /tmp/arinax_md.tar
```

## Available Scripts

- `scripts/start.sh` - Deploy and start with SSH tunnel
- `scripts/deploy.sh` - Deploy only
- `scripts/stop.sh` - Stop services
- `scripts/restart.sh` - Restart services
- `scripts/setup_ssh.sh` - Configure SSH keys
- `scripts/install_ansible.sh` - Install Ansible dependencies

## Manual Deployment

Run Ansible playbook directly:

```bash
ansible-playbook -i inventory.yaml playbooks/deploy_vm.yml
```

Deploy only specific parts using tags:

```bash
# Deploy only [tags]
ansible-playbook -i inventory.yaml playbooks/deploy_vm.yml --tags tagsnames

# Multiple tags
ansible-playbook -i inventory.yaml playbooks/deploy_vm.yml --tags tag1,tag2,...
```

Available tags: `system`, `dependencies`, `setup`, `conda`, `repositories`, `python`, `ui`, `docker`, `service`, `systemd` 
See deploy_vm.yml to know what each tags deploy

## Service Management

On the VM:

```bash
# Check status
systemctl status mxcubeweb-mxcube_vm1

# View logs
journalctl -u mxcubeweb-mxcube_vm1 -f

# Restart
sudo systemctl restart mxcubeweb-mxcube_vm1
```
