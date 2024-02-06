# "V:\Repos\Github\windows-packed-vmware-boxes\images\box\WS2019_1223_vmware.box"

Set-Location -Path $PSScriptRoot

vagrant box remove ws2019
vagrant box add ws2019 ../windows-packed-vmware-boxes/images/box/ws2019_1223_vmware.box

vagrant box remove W10
vagrant box add w10 ../windows-packed-vmware-boxes/images/box/W10e_22h2_020324_vmware.box

exit
