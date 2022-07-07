# base_rhel7

## Purpose
The base image is intended to convert a vendor-provided ISO disk into
an AWS AMI file. It's meant to be as bare-bones as possible. The absolute
minimum of packages are installed in the base image to save time and
resources on bare metal.

## Build Instructions
```shell
cd packer
export AWS_DEFAULT_REGION=<your/AWS/Region>
export AWS_ACCESS_ID=<YOURACCESSID>
export AWS_SECRET_KEY=<yoUR/seCRetKey>
./build.sh
```

Wait for the build to finish

## Tools required
### Packer

Packer is a tool for launching an ISO image and converting it to a number of virtual machines, in our case AWS AMI and eventually Azure or Google Compute.

Packer requires a few mandatory files, namely template.json and ks.cfg.

The template.json file describes the input and output formats (ISO and AWS AMI respectively) and provides some configuration settings (AWS_ACCESS_ID, admin user, admin password), whereas the ks.cfg is an anaconda kickstart file that provides the answers for performing an install (software packages to install, drivers to skip, disk partitions, SeLinux configuration).

The ks.cfg file has the minimum required packages to create a usable AMI on AWS from an Everything-DVD ISO file and it should be kept that way. Any additional packages installed at this stage are just consuming resources on expensive bare metal and really should be saved for the hardened Image build performed with Ansible (described later).

### Prerequisites

You must have **Git**, **Packer**, **OpenSSL**, and **VirtualBox** installed, have an AWS_ACCESS_ID and AWS_SECRET_KEY and AWS_DEFAULT_REGION, and have a copy of packer.exe in your path. You must clone this image repo to build.

**Git** can be downloaded from https://git-scm.com/downloads. As of this writing, the current version is 2.37.0. To install Git, open the downloaded file and follow the prompts. The defaults are fine for most users.

**Packer** can be downloaded from https://www.packer.io/downloads. You probably want the 64-bit version. As of this writing, the current version is 1.8.2.  To install packer, unzip the file and copy the packer.exe binary to somewhere in your path.

**OpenSSL** for Windows can be downloaded from https://slproweb.com/products/Win32OpenSSL.html.

**VirtualBox** can be downloaded from https://www.virtualbox.org/wiki/Downloads. As of this writing the current version is 6.1.34. To install VirtualBox, open the downloaded file and follow the prompts. The defaults are fine for most users.

You may have to reboot after installing VirtualBox.

You will need to download the ISO directly from [RedHat](https://access.redhat.com/products/red-hat-enterprise-linux), specifically the Red Hat Enterprise Linux 7.9 Binary DVD. An active subscription is required. The DVD ISO is about 4.2GB.

## What happens at each stage of the build

#### build.sh
1. Generate a random password
2. SHA512 Hash the random password
3. Inject the SHA512 hash into the kickstart file
4. Use Packer to build the image with the template
5. Replace the SHA512 hash with dummy text in the kickstart file

#### Packer template.json
1. Establish variables
2. Establish builder
    1. Virtualbox-ISO
    2. Headless
    3. Resources
    4. Boot command
    5. Shutdown command
    6. Result format
    7. CPUs
    8. Firmware
3. Establish provisioners
    1. sudoers - defines who is allowed to sudo
    2. cloud.cfg - Establishes data for cloud-init
    3. ansible.sh 
       1. Store image DNA
       2. Copy files to appropriate locations
       3. Restart Network Manager
       4. Copy certificate bundles
       5. Install certificates
       6. Disable mirrors
       7. Install PIP3
       8. Enable SeLinux PIP
       9. Install Ansible
    6. init.yaml
       1. Enable dracut FIPS
       2. Change SKEL permissions
    7. cleanup.sh - Remove unnecessary files and shrink filesystem
4. Establish post processors
   1. Make a local OVA copy
   2. install_image.sh
      1. Upload OVA to S3
      2. Import OVA as AMI
      3. Wait for import
      4. Rename AMI
      5. Wait for rename

#### ks.cfg (Kickstart)
1. Install from CDROM
2. Define locale to en_US.UTF-8
3. Declare US keyboard
4. Declare boot networking
5. Lock root account
6. Enable centos user
7. Enable firewalld
8. Define password encryption standard
9. Enforce SeLinux
10. Declare timeout for bootloader
11. Format virtual disk
12. Remove partitions
13. Declare partitions (STIG requirement)
14. Agree to EULA
15. Enable SSH and NetworkManager
16. Reboot

### Packages installed
* @Core
* OpenSSH clients
* OpenSCAP scanner
* Python3
* OpenSCAP default security guides
* Sudo
* Vim
* Curl
* Dracut-FIPS
* AIDE
* Pam & Pam PKCS11
* NetworkManager and dependencies
* Subscription manager
* Wget
* Unzip
* Cloud-init and dependencies
