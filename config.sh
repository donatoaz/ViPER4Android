##########################################################################################
#
# Magisk Module Template Config Script
# by topjohnwu
#
##########################################################################################
##########################################################################################
#
# Instructions:
#
# 1. Place your files into system folder (delete the placeholder file)
# 2. Fill in your module's info into module.prop
# 3. Configure the settings in this file (config.sh)
# 4. If you need boot scripts, add them into common/post-fs-data.sh or common/service.sh
# 5. Add your additional or modified system properties into common/system.prop
#
##########################################################################################

##########################################################################################
# Configs
##########################################################################################

# Set to true if you need to enable Magic Mount
# Most mods would like it to be enabled
AUTOMOUNT=true

# Set to true if you need to load system.prop
PROPFILE=false

# Set to true if you need post-fs-data script
POSTFSDATA=true

# Set to true if you need late_start service script
LATESTARTSERVICE=false

##########################################################################################
# Installation Message
##########################################################################################

# Set what you want to show when installing your mod

print_modname() {
  ui_print "*******************************"
  ui_print "  Viper4Android Magisk module  "
  ui_print "      by ShadySquirrel@XDA     "
  ui_print "                               "
  ui_print "   Based on original work by   "
  ui_print "           topjohnwu           "
  ui_print "*******************************"
}

##########################################################################################
# Replace list
##########################################################################################

# List all directories you want to directly replace in the system
# Check the documentations for more info about how Magic Mount works, and why you need this

# This is an example
REPLACE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

# Construct your own list here, it will override the example above
# !DO NOT! remove this if you don't need to replace anything, leave it empty as it is now
REPLACE="
"

##########################################################################################
# Permissions
##########################################################################################

set_permissions() {
  # Only some special files require specific permissions
  # The default permissions should be good enough for most cases

  # Here are some examples for the set_perm functions:

  # set_perm_recursive  <dirname>                <owner> <group> <dirpermission> <filepermission> <contexts> (default: u:object_r:system_file:s0)
  # set_perm_recursive  $MODPATH/system/lib       0       0       0755            0644

  # set_perm  <filename>                         <owner> <group> <permission> <contexts> (default: u:object_r:system_file:s0)
  # set_perm  $MODPATH/system/bin/app_process32   0       2000    0755         u:object_r:zygote_exec:s0
  # set_perm  $MODPATH/system/bin/dex2oat         0       2000    0755         u:object_r:dex2oat_exec:s0
  # set_perm  $MODPATH/system/lib/libart.so       0       0       0644

  # The following is default permissions, DO NOT remove
  set_perm_recursive  $MODPATH  0  0  0755  0644
}

##########################################################################################
# Custom Functions
##########################################################################################

# This file (config.sh) will be sourced by the main flash script after util_functions.sh
# If you need custom logic, please add them here as functions, and call these functions in
# update-binary. Refrain from adding code directly into update-binary, as it will make it
# difficult for you to migrate your modules to newer template versions.
# Make update-binary as clean as possible, try to only do function calls in it.

# This function extracts drivers and app.
install_v4a_module() {
  APK_PATH=$INSTALLER/app/ViPER4Android.apk
  DRIVER_PATH=$INSTALLER/drivers/libv4a_fx_jb_NEON.so

  ui_print "* Module path: $MODPATH"
  ui_print "* Temporary path: $INSTALLER"
  ui_print "* APK is in $APK_PATH"
  ui_print "* Default driver is $DRIVER_PATH"

  ui_print "* Extracting module files"
  unzip -o "$ZIP" 'drivers/*' 'app/*' -d $INSTALLER 2>/dev/null

  # do a bit of a cleanup, if some effects are already there
  # so far, blacklisting only AudioFX and MusicFX because I'm sure they exist.
  ui_print "* Checking for existing audio libs and effects"
  # MusicFX
  if [ -d "/system/priv-app/MusicFX" ]; then
    ui_print " -> Found MusicFX, blacklisting."
    mkdir -p "$MODPATH/system/priv-app/MusicFX" 2>/dev/null
    touch "$MODPATH/system/priv-app/MusicFX/.replace"
    # AudioFX
  elif [ -d "/system/priv-app/AudioFX" ]; then
    ui_print " -> Found AudioFX, blacklisting."
    mkdir -p "$MODPATH/system/priv-app/AudioFX" 2>/dev/null
    touch "$MODPATH/system/priv-app/AudioFX/.replace"
    # Dirac
  elif [ -d "/system/app/DiracAudioControlService" ]; then
    ui_print "-> Found Dirac ACS, blacklisting"
    mkdir -p "$MODPATH/system/app/DiracAudioControlService" 2>/dev/null
    touch "$MODPATH/system/app/DiracAudioControlService/.replace"
  elif [ -d "/system/app/DiracManager" ]; then
    ui_print "-> Found Dirac Manager, blacklisting"
    mkdir -p "$MODPATH/system/app/DiracManager" 2>/dev/null
    touch "$MODPATH/system/app/DiracManager/.replace"
  fi

  # create skeleton files and dirs
  ui_print "* Creating driver paths"
  mkdir -p $MODPATH/system/lib/soundfx 2>/dev/null

  # Check if device is maybe x86 - Atoms, i3/i5/i7 etc.
  if [ "$ARCH" = "x86" -o "$ARCH" = "x64" ]; then
    DRIVER_PATH=$INSTALLER/drivers/libv4a_fx_jb_X86.so
  else
    # device isn't x86, check if it really is ARM device
    if [ "$ARCH" != "arm" ] && [ "$ARCH" != "arm64" ]; then
      abort "!! Unsupported arch: $ARCH, aborting!"
    fi
  fi

  # copy driver
  if [ -f "$DRIVER_PATH" ]; then
    ui_print "* Copying V4A driver for $ARCH"
    cp -af $DRIVER_PATH $MODPATH/system/lib/soundfx/libv4a_fx_ics.so
  else
    abort "!! Driver missing! Aborting!"
  fi

  ui_print "* Modifying audio_effects.conf"

  CONFIG_FILE=/system/etc/audio_effects.conf
  HTC_CONFIG_FILE=/system/etc/htc_audio_effects.conf
  VENDOR_CONFIG=/system/vendor/etc/audio_effects.conf
  NEW_CONFIG_FILE=/vendor/etc/audio_effects.xml
  NEW_SYS_CONFIG_FILE=/system/vendor/etc/audio_effects.xml

  if [ -f "$CONFIG_FILE" ]; then
    ui_print "* Found $CONFIG_FILE, copying and modifying"
    mkdir -p $MODPATH/system/etc
    CFG="$MODPATH/$CONFIG_FILE"
    cp -af $CONFIG_FILE $CFG
    sed -i 's/^libraries {/libraries {\n  v4a_fx {\n    path \/system\/lib\/soundfx\/libv4a_fx_ics.so\n  }/g' $CFG
    sed -i 's/^effects {/effects {\n  v4a_standard_fx {\n    library v4a_fx\n    uuid 41d3c987-e6cf-11e3-a88a-11aba5d5c51b\n  }/g' $CFG
  fi

  if [ -f "$HTC_CONFIG_FILE" ]; then
    ui_print "* Found $HTC_CONFIG_FILE, copying and modifying"
    mkdir -p $MODPATH/system/etc
    CFG="$MODPATH/$HTC_CONFIG_FILE"
    cp -af $HTC_CONFIG_FILE $CFG
    sed -i 's/^libraries {/libraries {\n  v4a_fx {\n    path \/system\/lib\/soundfx\/libv4a_fx_ics.so\n  }/g' $CFG
    sed -i 's/^effects {/effects {\n  v4a_standard_fx {\n    library v4a_fx\n    uuid 41d3c987-e6cf-11e3-a88a-11aba5d5c51b\n  }/g' $CFG
  fi

  if [ -f "$VENDOR_CONFIG" ]; then
    ui_print "* Found $VENDOR_CONFIG, copying and modifying"
    mkdir -p $MODPATH/system/vendor/etc
    CFG="$MODPATH/$VENDOR_CONFIG"
    cp -af $VENDOR_CONFIG $CFG
    sed -i 's/^libraries {/libraries {\n  v4a_fx {\n    path \/system\/lib\/soundfx\/libv4a_fx_ics.so\n  }/g' $CFG
    sed -i 's/^effects {/effects {\n  v4a_standard_fx {\n    library v4a_fx\n    uuid 41d3c987-e6cf-11e3-a88a-11aba5d5c51b\n  }/g' $CFG
  fi

  if [ -f "$NEW_CONFIG_FILE" ]; then
    ui_print "* Found $NEW_CONFIG_FILE, copying and modifying"
    mkdir -p $MODPATH/vendor/etc
    CFG="$MODPATH/$NEW_CONFIG_FILE"
    cp -af $NEW_CONFIG_FILE $CFG
    sed -i 's/^    <libraries>/    <libraries>\n        <library name="v4a_fx" path="libv4a_fx_ics.so"\/>/g' $CFG
    sed -i 's/^    <effects>/    <effects>\n        <effect name="v4a_standard_fx" library="v4a_fx" uuid="41d3c987-e6cf-11e3-a88a-11aba5d5c51b"\/>/g' $CFG
  fi
  
  if [ -f "$NEW_SYS_CONFIG_FILE" ]; then
    ui_print "* Found $NEW_SYS_CONFIG_FILE, copying and modifying"
    mkdir -p $MODPATH/system/vendor/etc
    CFG="$MODPATH/$NEW_SYS_CONFIG_FILE"
    cp -af $NEW_SYS_CONFIG_FILE $CFG
    sed -i 's/^    <libraries>/    <libraries>\n        <library name="v4a_fx" path="libv4a_fx_ics.so"\/>/g' $CFG
    sed -i 's/^    <effects>/    <effects>\n        <effect name="v4a_standard_fx" library="v4a_fx" uuid="41d3c987-e6cf-11e3-a88a-11aba5d5c51b"\/>/g' $CFG
  fi

  # Looks like encrypted android doesn't like magic mounted apps - I got bunch of failures after module flash.
  # unless I wipe caches and let it wait. Warn users about that.
  if [ "`getprop ro.crypto.state`" = "encrypted" ]; then
    ui_print "**************************************"
    ui_print "/!\ Your device is encrypted."
    ui_print "/!\ You may encounter issues if app"
    ui_print "/!\ is installed as system app"
    ui_print " "
    ui_print "/!\ Please wipe device caches if you"
    ui_print "/!\ encounter app crashes after boot."
    ui_print "**************************************"
  fi

  # we're first checking if app is in the module. If user had removed apk file, warn.
  if [ -f "$APK_PATH" ]; then
    ui_print "* Installing V4A app"
    mkdir -p $MODPATH/system/priv-app/ViPER4Android 2>/dev/null
    cp -af $APK_PATH $MODPATH/system/priv-app/ViPER4Android/ViPER4Android.apk
  else
    ui_print "! V4A App is missing from module!"
    ui_print "! You will have to install the app manually!"
  fi

  ui_print " "
  ui_print "**************************************"
  ui_print "(i) Instalation finished."
  ui_print "***************************************"
}
