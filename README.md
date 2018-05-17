
# Setup Linux System on Zybo (zynq7010)
Document the process to setup linux on Zybo (zynq 7010) board.

## Prerequesites
* PetaLinux 2017.4 (installed at /opt/pkg/petalinux)
* Vivado 2017.4 (installed at /opt/Xilinx/Vivado/2017.4)

## Setup SD Card
* Use gparted on Ubuntu 16.04 LTS. Make sure SD card is unmounted (e.g. $sudo umount /media/<username>/E7A7-5FF9)
* Create two partitions:
	* 512MB, FAT32, Label:BOOT (make sure 4MB "free space proceeding" this partition)
	* All the rest of the SD card, EXT4, Label: ROOT_FS

## Root File System
Candidates to download (select one of them):
* [Linaro 17.08 (350MB)](http://releases.linaro.org/debian/images/developer-armhf/17.08/linaro-stretch-developer-20170706-43.tar.gz)
	* sudo tar xf linaro-jessie-developer-20161117-32.tar.gz --strip-components=1 -C <path>/ROOT_FS/
* [Ubuntu 16.04.4 minimal (134MB)](https://rcn-ee.com/rootfs/eewiki/minfs/ubuntu-16.04.4-minimal-armhf-2018-03-26.tar.xz)
	* tar xf ubuntu-16.04.2-minimal-armhf-2017-06-18.tar.xz
	* sudo tar xfvp ./*-*-*-armhf-*/armhf-rootfs-*.tar -C /media/rootfs/
	* sync
	* sudo chown root:root /media/rootfs/
	* sudo chmod 755 /media/rootfs/
* [Debian 9.4 minimal (127MB)](https://rcn-ee.com/rootfs/eewiki/minfs/debian-9.4-minimal-armhf-2018-03-26.tar.xz)

## Petalinux 

## Misc issues 
### USB wifi dongle issue
When booting Ubuntu 16.04 on Zybo, 'lsusb' can recognize the device, but 'dmesg' shows the firmware is missing. Also, the wlan0 interface is renamed.

```
[    1.384246] rtl8192cu: Chip version 0x10
[    1.388345] random: fast init done
[    1.478134] rtl8192cu: Board Type 0
[    1.480484] rtl_usb: rx_max_size 15360, rx_urb_num 8, in_ep 1
[    1.484932] rtl8192cu: Loading firmware rtlwifi/rtl8192cufw_TMSC.bin
[    1.490266] ieee80211 phy0: Selected rate control algorithm 'rtl_rc'
[    1.492261] usb 1-1: Direct firmware load for rtlwifi/rtl8192cufw_TMSC.bin failed with error -2
[    1.499644] usb 1-1: Direct firmware load for rtlwifi/rtl8192cufw.bin failed with error -2
[    1.506550] rtlwifi: Loading alternative firmware rtlwifi/rtl8192cufw.bin
==> [    1.512010] rtlwifi: Selected firmware is not available
...
==> [    6.159224] rtl8192cu 1-1:1.0 wlx74da38e1db0d: renamed from wlan0

```
Solutions:
* Run below on Zybo from newly installed Ubuntu 16.04 to fetch packages
```
> sudo apt-get update
> sudo apt-get dist-upgrade 
(Note: The latter command installs linux-firmware package, which resolved the firmware missing error above in dmesg log.)
```
* Or, alternatively, build from source. The wifi/usb related drivers should be enabled from Linux kernel customization/build. Say, 
```
> source /<path_to_xilinx>/SDK/<version>/settings64.sh
> export CROSS_COMPILE=arm-xilinx-linux-gnueabi-
> export ARCH=arm
> export PATH=$HOME/tutorial/u-boot-Digilent-Dev/tools:$PATH
> git clone -b master-next https://github.com/DigilentInc/Linux-
Digilent-Dev.git 
(Here assuming building from separate sync'ed linux kernel source, say, Linux-Digilent-Dev, instead of petalinux maintained/fetched linux source)
> cd Linux-Digilent-Dev/
> make mrproper
> make xilinx_zynq_defconfig
> make ARCH=arm menuconfig
```
Set (to 'y') the following options (leave any additional options that appear as their defaults):
Networking Support -> Wireless -> cfg80211 - wireless configuration API
Networking Support -> Wireless -> Generic IEEE 802.11 Networking Stack (mac80211)
Device Drivers -> Network device support -> Wireless LAN
Device Drivers -> Network device support -> Wireless LAN -> Realtek rtlwifi family of devices -> Realtek RTL8192CU/RTL8188CU USB Wireless Network
Device Drivers-> Multimedia support->
Media USB Adapters -> USB Video Class (UVC)
Device Drivers -> DMA engine support -> Async_tx: Offload support for the async_tx api
Floating point emulation -> Support for NEON in kernel mode
...
```
> make UIMAGE_LOADADDR=0x8000 uImage modules
```
Then install/copy the lib/modules and lib/firmware directoris to /media/<user>/ROOT_FS/lib. 
We install the modules in the temporary directory:
```
make INSTALL_MOD_PATH=/tmp/ modules_install firmware_install
```
We will have to copy these modules to the le system that is mounted in
/media/ROOT_FS/ executing:
```
sudo cp -r /tmp/lib/modules/3.18.0-xilinx-46110-gd627f5d/
/media/ROOT_FS/lib/modules/
sudo cp -r /tmp/lib/firmware
/media/ROOT_FS/lib/
```
Where the directory 3.18.0-xilinx-46110-gd627f5d may be di erent in your
case. The build and source folders inside 3.18.0-xilinx-46110-gd627f5d are not
necessary and are symbolic links, so we eliminate them:
```
sudo rm -r /media/ROOT_FS/lib/modules/3.18.0-xilinx-46110-
gd627f5d/build
sudo rm -r /media/ROOT_FS/lib/modules/3.18.0-xilinx-46110-
gd627f5d/source
```
* (Optional) wlan0 renamed to wlx74da38e1db0d fix
```
> sudo ln -s  /dev/null /etc/udev/rules.d/80-net-setup-link.rules
> sudo reboot now
```

* Configure wifi dongle
Although 'lsusb' recognized the usb wifi dongle, it won't start working unless configuration.
First, create file /etc/wpa_supplicant.conf, which can be generated:
```
> wpa_passphrase networkname password > /etc/wpa_supplicant/wpa_supplicant.conf
```
The contents shows below. Passwd is encrypted, you might want to remove the commented psk line which reserves the read-in password for your network.
```
# reading passphrase from stdin
network={
        ssid="<FILL SSID NAME>"
        #psk="<FILL SSID PASSWD>" <= Delete this line
        psk=6b27dc00618ad243a972e94b80f4c4bd159ad971212176b56453373ba31c9189
}
```
Now, execute below:
```
ubuntu@arm:~$ cat wlan.connect.sh 
sudo iw dev
sudo ip link set wlan0 up
sudo wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant.conf
sudo iw wlan0 link
sudo dhclient wlan0
ping 8.8.8.8
```
Now 'wlan0' should show up when 'ifcofing':
```
```


## References
* [Installing Ubuntu on Xilinx ZYNQ-7000 AP SoC Using PetaLinux](https://medium.com/developments-and-implementations-on-zynq-7000-ap/install-ubuntu-16-04-lts-on-zynq-zc702-using-petalinux-2016-4-e1da902eaff7)
* fpga.org:
	* [Yet Another Guide to Running Linaro Ubuntu Linux Desktop on Xilinx Zynq on the ZedBoard](http://fpga.org/2013/05/24/yet-another-guide-to-running-linaro-ubuntu-desktop-on-xilinx-zynq-on-the-zedboard/)
	* How to Design and Access a Memory-Mapped Device in Programmable Logic from Linaro Ubuntu Linux on Xilinx Zynq on the ZedBoard, Without Writing a Device Driver. [Part One](http://fpga.org/2013/05/28/how-to-design-and-access-a-memory-mapped-device-part-one/), [Part Two](http://fpga.org/2013/05/28/how-to-design-and-access-a-memory-mapped-device-part-two/).
* Sven Andersson's [Zynq Design From Scratch](svenand.blogdrives.com):
	* [Running Linaro Ubuntu on the Zedbaord](http://svenand.blogdrives.com/archive/199.html#.Wv0KH9ZlBhG)
* [Connect to wifi from linux cmdline](https://linuxconfig.org/connect-to-wifi-from-the-linux-command-line)
