#!/bin/bash
# Idea based on https://unix.stackexchange.com/a/489461

if [ -z "$@" ]
then
 echo "Provide package to download, abort."
 exit
fi

PKG=$@
PKGDIR= $(echo $PKG | tr " " "_"|head -c 20)
releasever=7
BASE_PATH=/tmp/offline
INSTALL_PATH=$BASE_PATH/install
DWL_PATH=$BASE_PATH/download
OFFLINE_REPO_PATH=/var/offlinerepo


# Use separte installdir to load all dependencies, see https://unix.stackexchange.com/a/174485
yum_output=$(yum install -q --downloadonly --installroot=$INSTALL_PATH/$PKGDIR --releasever=$releasever --downloaddir=$DWL_PATH/$PKGDIR $PKG 2>&1)


# Check if an error happened while downloading; if, exit script.
if [ $? -ne 0 ] 
then
  echo "An error occured could not download package, aborting."
  echo "Package: $PKG, Releasever: $releasever, Message: $yum_output"
  exit
fi


# Delete unnecessary data and create repo of downloaded packages
rm -rf $INSTALL_PATH
createrepo -q --database $DWL_PATH/$PKGDIR


# Create the repo-file
echo "[offline-$PKGDIR]
name=CentOS-$releasever - $PKG
baseurl=file://$OFFLINE_REPO_PATH/$PKGDIR
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-$releasever" > $DWL_PATH/offline-$PKGDIR.repo


# Output script end
echo "Downloaded `ls -1 $DWL_PATH/$PKGDIR | wc -l` files"
echo ""
echo "On offline-device: "
echo " move yum-config to: \"/etc/yum.repos.d/offline-$PKGDIR.repo\""
echo " to install use: \"yum --disablerepo=\* --enablerepo=offline-$PKGDIR install --nogpgcheck $PKG\""
