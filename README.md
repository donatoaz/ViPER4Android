# ViPER4Android Magisk module

This is a simple V4A module, for no frills setup - you simply grab it, flash it and use it.

No configuration, no additional frameworks, no special requirements, no hacks, no mess. It just works.

Module is based on original module made by [topjohnwu](https://github.com/topjohnwu).

Uses ViPER4Android 2.5.0.4 driver and **includes** [ViPER4Android FX Materialized](https://labs.xda-developers.com/store/app/com.pittvandewitt.viperfx), so you don't have to install anything.

**NOTE**: If you're searching for module version still using V4A Materialized app, search no more. You can find it [here](https://github.com/ShadySquirrel/ViPER4Android/releases), just find ones marked as 'materialized'.

**WARNING**: Since V4A app is systemlessly installed into /system/priv-app (just to stop your ROM from killing V4A too often), this module is possibly incompatible with AppSystemizer and similar modules and may cause undesirable/unpredictable behaviour when installed in conjuction with it. Be aware of this. If you want to use this module without provided app, edit updater-script manually or open an issue here/contact me on XDA to make flashable module without provided app.

## Requirements
* Android 5.0+ with fully functional Magisk installation,
* **No other sound mods installed** - if you have any, remove them before this module is installed,
* ARM/ARM64, x86 or x86_64 device with NEON support.

## Compatibility
* Android 5.x - Android 8.x
* Magisk v15 and later (uses template 1500)
* arm, arm64, x86 and x86_64 devices

## Module changelog
* 21.01.2018 - Module updates
	* Added support for XML audio effects configuration which some of new or Oreo updated devices are using
	* Added SEPolicy fixes for OxygenOS Oreo
	* Added SEPolicy fixes for other Oreo ROMs (tested on stock Mi A1 and Pixel XL)
* 27.12.2017 - Update to template version 1500
* 26.10.2017 - Improvements
	* Installation script is now more verbose, allows installation without an app (you'll still have to remove it manually from file) and includes fail-safe checks for arch, library etc,
	* Configuration file management is now bit different, still more to change,
	* New versioning system, allowing users to keep old module versions on their phones
	* Cosmetic changes.
	* Added a mention about version  [still using V4A Materalized](https://github.com/ShadySquirrel/ViPER4Android/releases)
* 08.10.2017 - Merged SELinux fixes
	* Thanks to [zertyuiop](https://github.com/zertyuiop/ViPER4Android)
* 06.09.2017 - Update to template version 1400
	* New template patchup
	* Changes in installation logic (removed unecessary unzip)
* 06.08.2017 - Initial commit. Included changes
	* Magisk Module Template v4
	* New update-binary script, based on original one
	* Changes for SELinux policy injection mechanism

## Credits
* [topjohnwu](https://github.com/topjohnwu): [Magisk](https://github.com/topjohnwu/Magisk) and [original Magisk module](https://github.com/Magisk-Modules-Repo/ViPER4Android/)
* [ViPER520 and ZhuHang](http://vipersaudio.com/blog/): ViPER4Android development ([official XDA thread](https://forum.xda-developers.com/showthread.php?t=2191223))
* [pittvandewitt and mr_white_214](https://forum.xda-developers.com/android/themes/app-viper4android-materialized-t3624655): [ViPER4Android Materialized](https://github.com/MrWhite214/v4a_material/) app

## Support
If you have any problems with module itself, not V4A driver or app, please open issue on [my issue tracker](https://github.com/ShadySquirrel/ViPER4Android/issues). There is no support thread, and there never will be.

### Issue tracking guidelines
If your problem with V4A is strictly connected to the module (module not installing, sepolicy not being injected etc. or not working, V4A app says everything is okay but problems with processing audio exist etc.), this is info you have to provide when you're opening issue on [my issue tracker](https://github.com/ShadySquirrel/ViPER4Android/issues):

* Module and Magisk version,
* Phone model, OS and version,
* List of installed modules,
* Is any other sound mod installed?
* Logs - logcat, FULL kmsg, Magisk log,
* audio_effects.conf file from /system/etc, /system/vendor/etc, or *wherever* is your audio effects configuration,
* A description of an issue or debugging info you may have or find usable.

Issues opened without required information will be automatically closed and discarded.

