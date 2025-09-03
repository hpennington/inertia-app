#!/usr/env/bin bash
mount -t virtiofs inertia_storage ~/Inertia
waydroid prop set persist.waydroid.width 300

#waydroid shell
#settings put global policy_control immersive.full=*
