# yumdownloadonly
Downloads a package with all dependencies using `yum` and creates repo-file for `CentOS 7`.

This is helpfull if you have a host which is not connected to the internet. On an online-host you have to execute the script, transfer the downloaded data to the offline host and finally execute the installation. 


# Full example
## On the ONLINE-host - DOWNLOAD package
Two download the data, you have two different possibilities: using the script directly or using a container. If the online-host does not run `CentOS 7` you should use the container-version.


### Downloading package using Script directly

Installation and prerequisites:
```bash
git clone https://github.com/handflucht/yumdownloadonly
yum install -y yum-plugin-downloadonly yum-utils createrepo
cd yumdownloadonly
```

Download everything to offline install `httpd`:
```bash
./offlinecopy.sh httpd
ls /tmp/offline/download

# httpd offline-httpd.repo
```

Now transfer the data of `/tmp/offline/download` to the offline-host, e.g. using an USB-device.

### Downloading package using Container
You might want to use container if your online-host isn't a CentOS-machine.

```bash
podman build -t yumdownloadonly https://github.com/handflucht/yumdownloadonly
```

Download everything to offline install `httpd`:
```bash
mkdir /var/data
podman run --rm -v /var/data:/tmp:z yumdownloadonly httpd
ls /var/data/offline/download

# httpd offline-httpd.repo
```

Please be aware, we create a new folder `/var/data` and called the mount with `:z`. This has to be done for SeLinux-reasons. Find more information here: https://github.com/containers/libpod/issues/3683#issuecomment-517239831.


Now transfer the data of `/var/data/offline/download` to the offline-host, e.g. using an USB-device.

## On the OFFLINE-host - INSTALL package

Copy the repository-data and the the repository-file to the correct location:
```bash
ls 
# httpd offline-httpd.repo
mv httpd /var/offlinerepo
mv offline-httpd.repo /etc/yum.repos.d/
```

Finally, start installation:
```bash
yum --disablerepo=\* --enablerepo=offline-httpd install --nogpgcheck httpd
```