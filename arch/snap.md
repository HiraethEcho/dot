## backup

首先运行 `pacman -Qe`，这个命令可以列出系统中所有手动指定安装的包，运行 `pacman -Qe >> list.txt` 可以将这个软件包名单保存到 `list.txt` 文件里面，再将这个文件保存到方便查看的地方，比如自己的手机里什么的，方便重装后参照这个名单将软件装回来。

之后是备份整个家目录，以便重装完后恢复绝大多数的个人数据。我找到一个闲置的空的移动硬盘，不是空的也没关系，只要剩余空间够放下家目录的内容就行，将其挂载在 `/mnt` 目录下，并新建一个空文件夹 `backup`。为了在恢复数据时保留所有文件的权限，我使用 rsync 命令：

```
sudo rsync -avrh --progress /home/ /mnt/backup/
```

重启进入新系统后，因为还未安装图形界面，会进入 tty，因为之后要恢复家目录文件，所以这里暂时先不用普通用户登录，而是登录进 root 用户，开始着手恢复家目录文件，将之前用于备份家目录的移动硬盘重新挂载到 `/mnt` 目录，一样使用 rsync 恢复文件，只需将之前备份命令里两个路径互换位置即可：

```
rsync -avrh --progress /mnt/backup/ /home/
```

恢复过程同样需要较长时间，请耐心等待，恢复完成后退出 root 登录，使用普通用户登录。参照之前备份的软件包列表将所需的软件包装回来，再启用一些需要的服务，就可以正常使用了，就和重装前一样。
## 快照

btrfs 文件系统最吸引人的特性之一就是快照，通过快照可以方便地回滚系统，虽然我们也可以在命令行[手动创建快照](https://sspai.com/link?target=https%3A%2F%2Fwiki.archlinux.org%2Ftitle%2FBtrfs%23Snapshots)，但多少有些麻烦，为了更好地创建和管理快照，可以借助一些其他工具，我使用的是 LinuxMint 团队开发的 [Timeshift](https://sspai.com/link?target=https%3A%2F%2Fgithub.com%2Flinuxmint%2Ftimeshift)，注意 Timeshift 只支持 Ubuntu 类型的子卷布局，这在之前的分区过程中已经搞定了。只需从 [AUR](https://sspai.com/link?target=https%3A%2F%2Faur.archlinux.org%2Fpackages%2Ftimeshift) 安装，之后打开按照向导一路设置就好了，记得要启用 cronie 服务，`sudo systemctl enable cronie.service --now`，以保证 Timeshift 能够定时创建快照。此外也可以安装 [timeshift-autosnap](https://sspai.com/link?target=https%3A%2F%2Faur.archlinux.org%2Fpackages%2Ftimeshift-autosnap)，这个包添加了一个 pacman hook，可以在每次系统升级前自动创建快照。

接下来安装 [grub-btrfs](https://sspai.com/link?target=https%3A%2F%2Farchlinux.org%2Fpackages%2Fcommunity%2Fany%2Fgrub-btrfs%2F)，这个软件可以在每次重新生成 grub 配置文件时添加快照的入口，可以在不恢复快照的情况下直接启动进入快照，方便故障排查。若是觉得每次创建快照后都要手动运行 `grub-mkconfig` 过于麻烦，这个包还提供了一个 systemd 服务 `grub-btrfsd.service`，需先安装 grub-btrfs 的可选依赖 [inotify-tools](https://sspai.com/link?target=https%3A%2F%2Farchlinux.org%2Fpackages%2Fcommunity%2Fx86_64%2Finotify-tools%2F)，然后启用这个服务 `sudo systemctl enable grub-btrfsd.service --now` 就可以在每次创建快照后自动生成 grub 配置文件了，不过这个服务默认监视的快照路径在 `/.snapshots`，而 Timeshift 创建的快照是一个动态变化的路径，想要让它监视 Timeshift 的快照路径需要编辑 service 文件。一般情况下不推荐直接编辑位于 `/usr/lib/systemd/system/` 下的 service 文件，因为软件包升级会将编辑后的文件覆盖掉，还好 systemd 提供了解决方案，运行 `sudo systemctl edit --full grub-btrfsd` ，这个命令会将 `/usr/lib/systemd/system/grub-btrfsd.service` 文件复制到 `/etc/systemd/system/grub-btrfsd.service`，再用系统默认的文件编辑器打开，这样编辑后的文件就不会被覆盖掉了，找到下面这一行：

```
ExecStart=/usr/bin/grub-btrfsd --syslog /.snapshots
```

修改为：

```
ExecStart=/usr/bin/grub-btrfsd --syslog --timeshift-auto
```

这样 grub-btrfs 就会监视 Timeshift 创建的快照了。

Timeshift 创建的快照默认是可读写的，但若用其他的快照管理程序，创建的快照可能是只读的，这种情况下，直接启动进入快照可能会发生错误，这种情况 grub-btrfs 也提供了[解决方案](https://sspai.com/link?target=https%3A%2F%2Fgithub.com%2FAntynea%2Fgrub-btrfs%2Fblob%2Fmaster%2Finitramfs%2Freadme.md)，grub-btrfs 提供了一个 `grub-btrfs-overlayfs` 钩子，编辑 `/etc/mkinitcpio.conf`，找到 `HOOKS` 一行，在括号最后添加 `grub-btrfs-overlayfs`，比如这样：

```
HOOKS=(base udev autodetect modconf block filesystems keyboard fsck grub-btrfs-overlayfs)
```

然后重新生成 initramfs，`sudo mkinitcpio -P`。在这之后创建的只读快照，将会以 overlayfs 的形式启动进入，所有的改动将会存储在内存里，重启后都会消失，逻辑和大多数系统的 live-cd 安装镜像差不多。

