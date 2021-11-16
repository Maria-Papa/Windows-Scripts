@echo off
REM User input for new vm name.
set /P vm_name="New VM name: "

REM You can change these variables, so they match with your VirtualBox files location.
set vb_manager="D:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
set vb_vm="D:\Program Files\Oracle\VirtualBox\VirtualBoxVM.exe"
set vdi_location="D:\VMs\%vm_name%"
set iso_download_path="C:\Users\%USERNAME%\Downloads"

REM If you already have the Ubuntu LTS 20.04 ISO on your pc, you can define its path here, to skip more writing.
set iso_path="D:\Installs\Dev_Installs\ubuntu-20.04.3-desktop-amd64.iso"

:choice_1
REM User input for whether it will be a default or not creation.
set /P use_defaults="Do you want to use defauts[Y/N]?"

if /I "%use_defaults%"=="Y" goto :defaults_on
if /I "%use_defaults%"=="N" goto :defaults_off
goto :choice_1

:defaults_on
echo "defaults_on"

REM Feel free to change these default variables to your liking!
set /A cpus=1
set /A memory_mb=6300
set /A vram_mb=20
set /A disk_mb=10000

goto :start

:defaults_off
echo "defaults_off"

REM User input for preferred Vdi Location, Number of CPUs, Memory MB, vRAM MB and Disk MB.
set /P vdi_location="Vdi location: "
set /P cpus="Number of CPUs: "
set /P memory_mb="MB of memory: "
set /P vram_mb="MB of vRAM: "
set /P disk_mb="MB of disk storage: "

goto :start

:start
REM Create a vm with OS Ubuntu x64 and the provided VM Name and Vdi Location.
%vb_manager% createvm --name %vm_name% --ostype Ubuntu_64 --basefolder %vdi_location% --register

REM Configure vm settings.
%vb_manager% modifyvm %vm_name% --cpus %cpus% --memory %memory_mb% --vram %vram_mb% --rtcuseutc on --pae off
%vb_manager% modifyvm %vm_name% --nic1 bridged --bridgeadapter1 "Killer E2400 Gigabit Ethernet Controller"
%vb_manager% modifyvm %vm_name% --graphicscontroller vmsvga
%vb_manager% modifyvm %vm_name% --audioout on --usb on
%vb_manager% modifyvm %vm_name% --clipboard-mode bidirectional --draganddrop bidirectional

REM Create a new medium with the provided Name, Size.
%vb_manager% createmedium --filename %vdi_location%\%vm_name%.vdi --size %disk_mb% --format VDI

REM Modify and attach storage mediums.
%vb_manager% storagectl %vm_name% --name "IDE" --add ide --controller PIIX4
%vb_manager% storageattach %vm_name% --storagectl "IDE" --port 0 --device 0 --type dvddrive --medium %iso_path%
%vb_manager% storagectl %vm_name% --name "SATA" --add sata --controller  IntelAhci       
%vb_manager% storageattach %vm_name% --storagectl "SATA" --port 1 --device 0 --type hdd --medium %vdi_location%\%vm_name%.vdi

:choice_2
REM User input for whether he/she needs Ubuntu x64 ISO to be downloaded.
set /P donwload_iso="Do you want to download Ubuntu ISO[Y/N]?"
if /I "%donwload_iso%"=="Y" goto :donwload_ubuntu
if /I "%donwload_iso%"=="N" goto :set_iso_path
goto :choice_2

:donwload_ubuntu
REM Before downloading check if file already exists.
if exist %iso_path% (
  	echo "The file 'ubuntu-20.04.3-desktop-amd64.iso' already exists in the path %iso_path%"
) else (
	REM User input for ISO Download Path.
	set /P iso_download_path="ISO Download path: "
	cd %iso_download_path%
	curl.exe --url https://releases.ubuntu.com/20.04/ubuntu-20.04.3-desktop-amd64.iso --output ubuntu-20.04.3-desktop-amd64.iso
)
goto :choice_3

:set_iso_path
REM User input for ISO Path and Name.
set /P iso_path="ISO path: "
set /P iso_name="ISO name (add .iso to the end): "

REM Check if the given ISO exists in the given Path.
if exist %iso_path%\%iso_name% (
	echo "The file 'ubuntu-20.04.3-desktop-amd64.iso' already exists in the path %iso_path%"
	goto :choice_3
) else (
	echo "The file %iso_name% is not found in the path %iso_path%"
	goto :set_iso_path
)

:choice_3
REM User input for whether he/she wants the new vm to start.
set /P start_vm="Do you want to start vm %vm_name%[Y/N]?"
if /I "%start_vm%"=="Y" goto :start_vm
if /I "%start_vm%"=="N" goto :exit
goto :choice_3

:start_vm
REM Start the ne vm.
%vb_manager% startvm %vm_name%
goto :exit

:exit
echo "Goodbye!"
pause
exit
