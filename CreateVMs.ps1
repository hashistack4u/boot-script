$ErrorActionPreference = "Stop"

Function New-FlatcarVM {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$vmName,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$dnsDomainName,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$IP
    )

    # TODO: Add "shell: /bin/false" for hashistack users
	$hostname = $vmName -replace "hashistack4u-",""
    $ignitionMetadata = @"
variant: flatcar
version: 1.0.0
kernel_arguments:
  should_exist:
    - flatcar.autologin
passwd:
  groups:
    - name: hashistack
  users:
    - name: core
      primary_group: hashistack
      ssh_authorized_keys:
        - $sshKey
    - name: consul
      primary_group: hashistack
    - name: nomad
      primary_group: hashistack
      groups:
        - docker
    - name: vault
      primary_group: hashistack
    - name: loki
      primary_group: hashistack
storage:
  files:
    - path: /etc/hostname
      overwrite: true
      mode: 0644
      contents:
        inline: $hostname
    - path: /etc/resolv.conf
      overwrite: true
      mode: 0644
      contents:
        inline: |
          nameserver 127.0.0.53
          nameserver $dnsServer1
          nameserver $dnsServer2
          search $dnsDomainName
    - path: /etc/hosts
      overwrite: true
      mode: 0644
      contents:
        inline: |
          127.0.0.1 localhost
          192.0.2.11 server-1.$dnsDomainName server-1
          192.0.2.12 server-2.$dnsDomainName server-2
          192.0.2.13 server-3.$dnsDomainName server-3
    - path: /etc/hashistack.env
      mode: 0640
      group:
        name: hashistack
      contents:
        inline: |
          AZURE_TENANT_ID=$AzureTenantID
          CONSUL_DATACENTER=$ConsulDatacenter
          CONSUL_ENCRYPT_KEY=$ConsulEncryptKey
          CONSUL_EXTRA_PARAM="-bind=$IP"
          CONSUL_HTTP_ADDR=$hostname.$($dnsDomainName):8501
          CONSUL_HTTP_SSL=true
          DNS_DOMAIN_NAME=$dnsDomainName
          DNS_SERVER1=$dnsServer1
          DNS_SERVER2=$dnsServer2
          NOMAD_EXTRA_PARAM="-bind=$IP -meta=server=true"
          NOMAD_ROLE=server
          VAULT_AZUREKEYVAULT_VAULT_NAME=$AzureVaultName
          VAULT_AZUREKEYVAULT_KEY_NAME=$AzureVaultKeyName
          VAULT_API_ADDR=https://$hostname.$($dnsDomainName):8200
          VAULT_CLUSTER_ADDR=https://$hostname.$($dnsDomainName):8201
          VAULT_RAFT_NODE_ID=$hostname.$dnsDomainName

          # FixMe: We should not need these
          AZURE_CLIENT_ID=$AzureClientID
          AZURE_CLIENT_SECRET=$AzureClientSecret
    - path: /etc/sysctl.d/90-unprivileged.conf
      mode: 0644
      contents:
        inline: |
          net.ipv4.ip_unprivileged_port_start = 0
          net.ipv4.ping_group_range = 0 2147483647
    - path: /etc/flatcar/update.conf
      overwrite: true
      mode: 0644
      contents:
        inline: |
          SERVER=disabled
    - path: /etc/extensions/hashistack.raw
      contents:
        source: $sysextUrl
        verification:
          hash: sha256-$sysextVersionSHA256
  directories:
    - path: /opt/hashistack
      mode: 0770
      group:
        name: hashistack
systemd:
  units:
    - name: systemd-resolved.service
      mask: true
    - name: mnt-bootscript.mount
      enabled: true
      contents: |
        [Unit]
        Description=cifs mount
        After=network-online.service
        [Mount]
        What=//$gateway/bootScript$
        Where=/mnt/bootscript
        Options=username=$smbUser,password=$smbPasswd,workgroup=$smbDomain,rw,uid=500,gid=1000,dir_mode=0775,file_mode=0775
        Type=cifs
        [Install]
        WantedBy=multi-user.target
    - name: mnt-bootscript.automount
      enabled: true
      contents: |
        [Unit]
        Description=cifs automount
        [Automount]
        Where=/mnt/bootscript
        [Install]
        WantedBy=multi-user.target
"@
    echo $ignitionMetadata > ignition.yaml
    butane.exe --strict ".\ignition.yaml" -o ".\ignition.json"
    if ($? -ne $true) { throw "Butane failed" }

    New-VHD -ParentPath "$PSScriptRoot\$image" -Path "$PSScriptRoot\$vmName.vhdx" -Differencing
    New-VM -Name $vmName -SwitchName "hashistack4u" -MemoryStartupBytes 2048MB -VHDPath "$PSScriptRoot\$vmName.vhdx" -Generation 2
    Set-VMMemory -VMName $vmName -DynamicMemoryEnabled $true
    Set-VMProcessor -VMName $vmName -Count 4
    Set-VMFirmware -EnableSecureBoot "Off" -VMName $vmName

    # Use static MAC address for server nodes
    [int]$serverNum = $vmName.Substring($vmName.Length-1,1)
    if ($vmName -like "hashistack4u-server-*") {
      $macAddress = "00-15-5D-00-00-1" + $serverNum
      Set-VMNetworkAdapter -VMName $vmName -StaticMacAddress  $macAddress
    }
    
    kvpctl.exe "$vmName" add-ign ignition.json
    Remove-Item -Path ".\ignition.yaml" -Force
    Remove-Item -Path ".\ignition.json" -Force
    
    Start-VM -Name $vmName
}

. .\.settings.ps1

Get-Process vmconnect -ErrorAction:SilentlyContinue | ForEach-Object {$_.Kill()}
for($i=0; $i -lt $servers.count; $i++) {
    $server = ([array]$servers.Keys)[$i]
    try {
        New-FlatcarVM -vmName "hashistack4u-$server" -dnsDomainName $dnsDomainName -IP $servers[$i]
        if ($i -eq 0) {
          vmconnect.exe $env:COMPUTERNAME "hashistack4u-$server"
        }
    } catch {
        Write-Host $_
        Write-Host $_.ScriptStackTrace
        $ErrorActionPreference = "Continue"
        Write-Warning "Creation of VM $server failed. Cleaning up..."
        Remove-VM -VMName "hashistack4u-$server" -Force
        Remove-Item -Path "$PSScriptRoot\hashistack4u-$server.vhdx" -Force
        break
    }
}
