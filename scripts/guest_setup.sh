#!/usr/env/bin bash
sudo vim /var/lib/waydroid/waydroid.cfg
[properties]
ro.hardware.gralloc=default
ro.hardware.egl=swiftshader

sudo waydroid upgrade -o

#waydroid shell
#settings put global policy_control immersive.full=*

sudo mount -t virtiofs inertia_storage ~/Inertia
waydroid prop set persist.waydroid.width 400 



