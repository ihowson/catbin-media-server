# catbin media server

A home media server.

Tech stack:

* Ubuntu 18.04 LTS
* ZFS for storage
* root-on-ZFS
* USB drive for boot (mostly read-only)
* Deployment using Ansible
* CrashPlan for backups
* All applications deployed in Docker containers using portainer and linuxserver.io.

This is based on what I learned running 'tyler', an almost-15-year-old Ubuntu installation. For more information on the design choices, see 'Lessons Learned' below.

The Ansible playbook was heavily inspired by Dave Stephens' (ansible-nas)[https://github.com/davestephens/ansible-nas].

## Installation

1. Do a bare installation of Ubuntu 18.04 LTS on a machine. I'm using the (mini ISO)[ http://archive.ubuntu.com/ubuntu/dists/bionic/main/installer-amd64/current/images/netboot/mini.iso].

### Partitioning for a VM

If you're testing in a VM, create one disk (8GB) for the boot drive and one (or more) for the ZFS volumes. Installation will happen to the boot volume originally and be migrated to ZFS later.

The boot drive gets a single partition mounted to `/`. The ZFS volume can be left blank as ZFS works better with bare (unpartitioned) drives.

### Partitioning for production hardware

Create a single partition on the USB drive.

2. Install packages to support ansible

    sudo apt install net-tools openssh-server

3. Install your ssh key

    ssh-copy-id -i ~/.ssh/id_rsa.pub ian@192.168.56.101

4. Pre-install configuration

Edit `ansible/inventory` with your server's IP address.

5. Run the pre-migration playbook

'premigration' installs the base system enough to interact with ZFS. The idea is that you run this, move the root partition to ZFS, reboot and continue main installation afterward.

If you don't want your root partition on ZFS, feel free to skip ahead to 'Run the main playbook'.

Run:

    ansible-playbook -i config/inventory tasks/premigration.yml -b -K

6. Set up your ZFS volumes

How you do this depends on what you're trying to build, but here's how I do it.

TODO

7. Migrate the root partition to ZFS

TODO

Move the old root partition to make sure you're not accidentally running it.

Reboot to make sure everything is working correctly.

8. Run the main playbook

    ansible-playbook -i config/inventory playbook.yml -b -K

(`deploy-main.sh` does this, so you don't have to constantly refer back to these docs.)

This will install all of the applications, containers and configs.

9. Enjoy!

To get started, navigate to http://{server ip}/

## Changing stuff

You will probably want to change configs and applications at some point.

One of my Lessons Learned From Tyler (tm) was that it's difficult to keep track of changes as the machine ages.

The better way is to fork and modify this repo and use Ansible to deploy your changes. This way, you have a log of what's changed and can reproduce it anytime.

    ansible-playbook -i config/inventory playbook.yml -b -K

`docker-compose.yml` is pretty key in this; it defines what applications are deployed and parts of their config.

## Hardware

You can use any hardware, but I'm using:

* ?? xeon or amd with ecc
* 16GB of ECC RAM (sadly, CrashPlan uses a ton)
* Cheap disks. I'm just buying used disks on eBay and replacing them if they fail or if I need more space. 8 bays is tons of space for my needs, I can tolerate occasional failures, and I want room to expand really large in the future if needed. Stick with surveillance drives, ES or WD Red; desktop drives tend to die when left running nonstop for months.

You don't *need* ECC RAM, but it is recommended for use with ZFS, or anything important, really. I expand on this more at {TODO: blog URL}.

Plex requires a bit of CPU power for live transcoding, so this isn't suitable for an Atom NAS box or Raspberry Pi.

## What about playback?

Once upon a time, I built little Linux machines with remote controls running Kodi. They were never reliable and required a lot of setup and maintenance.

Nowadays I just use Plex with Roku or Apple TV devices. This isn't quite as nice as Kodi frontends, but saves a ton of maintenance work. Roku sticks start at $29 now and are very recommended.

## What does 'catbin' mean?

We lived in Munich for a while. { TODO story }

## Mirroring or RAIDZ2?

TODO

## Lessons learned from tyler

* Kernel upgrades easily break booting, and this machine will usually run unattended.
* md-RAID1 complicates everything and doesn't guarantee data integrity
* root-on-ZFS cuts maintenance overhead
* Applications should go in VMs or containers. Without this, upgrades to the underlying OS need to happen big-bang style, which costs a lot of time. In containers, applications can be migrated one at a time.
* Since tyler was deployed, kind third parties have developed off-the-shelf containers for everything useful. There's no need to do installations manually any more.
* Put every application in a separate isolated user account. Containers do this for you anyway.
* Have a 'public view' of the storage volumes with bind mounts to the underlying storage layout. This way, you can change volume/zvol/RAID layouts at will but not have to reconfigure applications.
* ZFS mirroring is much simpler to work with than RAIDZx, so long as the cost/size tradeoffs are acceptable.
* CrashPlan sucks up a lot of RAM but can't be beat for price.
* Using extra boot drives consumes SATA ports.
* Buying bigger drives and using less of them can be cheaper than adding SATA ports.
* Cheap SATA cards usually don't work, again pushing you to fewer bigger drives.

`catbin` is intended to be easier to maintain, easier to set up, and easier to upgrade.
