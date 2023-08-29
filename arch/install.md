# Install Arch

## Minimal install
### network and time
First, start from U disk.

set up network:
```sh
iwctl
[iwd] station wlan0 connect AMSS
```
time
```sh
timedatectl set-ntp true
timedatectl status
```
change source for pacman  `vim /etc/pacman.d/mirrorlist`

```text
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch
```
### mount and install

```sh
mkfs.btrfs  -L btrfs-arch /dev/nvme0n1p5
mkswap /dev/nvme0n1p6    # 格式化 swap 分区
```
mount and create subvolume
```sh
mount -o compress=lzo /dev/nvme0n1p3 /mnt

btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@logs
btrfs subvolume create /mnt/@tmp
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@snapshots
```


check and umount
```sh
btrfs subvolume list /mnt
```
should looks like
```sh
ID 256 gen 405 parent 5 top level 5 path @
ID 257 gen 409 parent 5 top level 5 path @home
ID 258 gen 409 parent 5 top level 5 path @logs
ID 259 gen 404 parent 5 top level 5 path @tmp
ID 261 gen 310 parent 5 top level 5 path @cache
ID 262 gen 288 parent 5 top level 5 path @snapshots
```
```sh
umount /mnt
```
mount subvolume
```sh
mount -o noatime,nodiratime,compress=lzo,subvol=@ /dev/nvme0n1p3 /mnt
mkdir -p /mnt/{btrfs-root,boot/efi,home,var/{log,lib/{docker,build},cache/pacman},tmp,.snapshots}
mount -o noatime,nodiratime,compress=lzo,subvol=@home /dev/nvme0n1p3 /mnt/home
mount -o noatime,nodiratime,compress=lzo,subvol=@logs /dev/nvme0n1p3 /mnt/var/log
mount -o noatime,nodiratime,compress=lzo,subvol=@tmp /dev/nvme0n1p3 /mnt/tmp
mount -o noatime,nodiratime,compress=lzo,subvol=@cache /dev/nvme0n1p3 /mnt/var/cache
mount -o noatime,nodiratime,compress=lzo,subvol=@snapshots /dev/nvme0n1p3 /mnt/.snapshots
```


disable cow
```
chattr +C /mnt/tmp
chattr +C /mnt/var/cache
```
enable swap `swapon /dev/sda2`

mount efi

```sh
mount /dev/nvme0n1p1 /mnt/boot/efi
```
install and genfstab

```
pacstrap -K -M /mnt base base-devel vim base base-devel linux linux-firmware btrfs-progs networkmanager neovim git sudo grub os-prober efibootmgr amd-ucode btrfs-assistant
genfstab -U /mnt >> /mnt/etc/fstab
```
- -G Avoid copying the host’s pacman keyring to the target.
- -i Prompt for package confirmation when needed (run interactively).
- -K Initialize an empty pacman keyring in the target (implies -G).
- -M Avoid copying the host’s mirrorlist to the target.

### chroot and set up
chroot by `arch-chroot /mnt`
add archlinuxcn
'vim /etc/pacman.conf'
```text
[archlinuxcn]
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch
```
set locale etc
```sh
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime #替换Region/City为你所在区域
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
systemctl enable NetworkManager.service
hostnamectl set-hostname YOUR-HOSTNAME
```

`vim /etc/mkinitcpio.conf`
添加 btrfs 到 MODULES=(...)行
找到 HOOKS=(...)行，更换fsck为btrfs
最终你看到的/etc/mkinitcpio.conf文件格式为

```text
MODULES=(btrfs)
HOOKS=(base udev autodetect modconf block filesystems keyboard btrfs)
```
然后重新生成 initramfs，`mkinitcpio -P`

add user
```sh
passwd root
useradd -m -G wheel  USERNAME
passwd USERNAME
```
权限：之后运行 `visudo`，如果环境变量没有指定默认编辑器，会提示选择，选择一个之后会进入文件编辑界面，找到 `# %wheel ALL=(ALL:ALL)` 一行，删除最前面的井号注释，这样所有在 wheel 用户组的用户都可以使用 sudo 命令了，或者要是不想每次运行 sudo 都要输入密码，可以取消注释 `%wheel ALL=(ALL:ALL) NOPASSWD: ALL` 这一行，但这样可能会降低系统的安全性。
install grub

 去掉 quiet 参数，调整 loglevel 值为 5 ，加入 nowatchdog 参数
sed -i "s|GRUB_CMDLINE_LINUX_DEFAULT.*|GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=5 nowatchdog\"|" /etc/default/grub
```sh
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch --recheck
```
去掉 quiet 参数，调整 loglevel 值为 5 ，加入 nowatchdog 参数
sed -i "s|GRUB_CMDLINE_LINUX_DEFAULT.*|GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=5 nowatchdog\"|" /etc/default/grub
```
grub-mkconfig -o /boot/grub/grub.cfg
```
### quit and reboot

```
exit #退出chroot
umount /mnt/boot/efi
umount /mnt/home
umount /mnt
reboot
```
## Basic set up

## Apps
