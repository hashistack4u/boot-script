# HashiStack boot script
This repository is used to develop boot script for [Flatcar Container Linux](https://www.flatcar.org). It configures [Hashistack as systemd-sysext image](https://github.com/hashistack4u/sysext) in it.

Script is by design as simple as possible which why most of the configurations are hardcoded and only minimal amount of parameters is included.

To enable rapid development process, local Hyper-V virtual machines are used for testing these scripts.

# Architeture
* Official Flatcar image
* Hashistack sysext image
* Shared "hashistack" group for all components.
* Dedicated non-root user for each component.
* Most of the settings in static configuration files.
* Environment specific settings are defined in dynamic configuration files and in environment variable file `/etc/hashistack.env`
* Vault with [auto-unseal with Azure Key Vault](https://developer.hashicorp.com/vault/docs/configuration/seal/azurekeyvault).
* Using condition `ConditionDirectoryNotEmpty=` / `ConditionFileNotEmpty` in systemd units to prevent services from starting until they are configured.
* Use Consul as default DNS server.
  * Use hosts file between servers to make sure that they can communicate with each others even when DNS resolutions are failing.

# TODO
## Generic
* Store data to secondary disk and support re-creating VMs when keeping it
* Get server certificate(s) from Azure Key Vault
* Split Ignition configuration to two files:
  * Common settings for all envs.
  * Extra settings for this lab.

## Vault
* Allow configuring `cluster_name`
* Use Azure Key Vault to detect if this is initial deployment or not.
* Use FQDN names in cluster configuration
* Store root token and recovery keys to Azure Key Vault


# Development
## Configuring development environment
In example configuration we are using subnet `192.0.2.0/24` which is reserved for documentation in [RFC 5737](https://datatracker.ietf.org/doc/html/rfc5737).

1. Create virtual network with [NAT enabled](https://learn.microsoft.com/en-us/virtualization/hyper-v-on-windows/user-guide/setup-nat-network)
```powershell
New-VMSwitch -SwitchName "hashistack4u" -SwitchType Internal
New-NetIPAddress -IPAddress "192.0.2.1" -PrefixLength 24 -InterfaceIndex $((Get-NetAdapter -Name "vEthernet (hashistack4u)").ifIndex)
New-NetNat -Name "hashistack4u" -InternalIPInterfaceAddressPrefix "192.0.2.0/24"
```
2. Copy `.settings.ps1.template` to name `.settings.ps1` and `dhcpsrv.ini.template` to name `dhcpsrv.ini` and update those to match with your environment.
3. Install and run [DHCP Server for Windows](https://www.dhcpserver.de)
4. Create SMB share which allow us share files with virtual machines:
```powershell
$Parameters = @{
	Name = 'bootScript$'
	Path = $pwd.Path
	FullAccess = '<smb user>'
}
New-SmbShare @Parameters
```
5. Add this to your local SSH client configuration file `~/.ssh/config` to enable error free SSH connections to VMs which are constantly re-created.
```
Host 192.0.2.*
  User core
  LogLevel ERROR
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
```

## Testing
1. Create dev VMs by running script: `.\CreateVMs.ps1`
2. SSH to nodes and run script `/mnt/bootscript/scripts/00_all.sh`
