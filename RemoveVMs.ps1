. .\.settings.ps1

forEach($server in $servers.keys) {
    Stop-VM -VMName "hashistack4u-$server" -TurnOff
    Remove-VM -VMName "hashistack4u-$server" -Force
    Remove-Item -Path "$PSScriptRoot\hashistack4u-$server.vhdx" -Force
}
