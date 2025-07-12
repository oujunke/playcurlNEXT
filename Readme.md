# To pass Google Play Integrity checks, follow these steps:
## 1. Install [Magisk](https://github.com/topjohnwu/MagiskManager) or [KernelSU](https://github.com/tiann/KernelSU) or [KernelSU-Next](https://github.com/KernelSU-Next/KernelSU-Next) and enable Zygisk (‌Required‌)
## 2. Download the [‌PlayIntegrityFixFork‌](https://github.com/oujunke/PlayIntegrityFixFork) module (‌Required‌) (Device fingerprint spoofing)
## 3. Download the [‌playcurlNEXT‌](https://github.com/oujunke/playcurlNEXT) module (Optional) (Automated fingerprint updates)
## 4. Download the [‌TrickyStore‌](https://github.com/oujunke/TrickyStore) module (‌Required‌) (Device certificate configuration)
## 5. Prepare a valid ‌KeyBox.xml‌ file (‌Required‌) (Device certificate spoofing)Free from [KeyBoxSell](https://t.me/KeyBoxSell)
### (Note: Steps marked as "Required" are essential for bypassing integrity checks.)

## 1. ‌Key Terms Clarification:‌

## 2. ‌Zygisk‌: Magisk's Zygote injection mechanism for system-level modifications.
## 3. ‌Fingerprint Spoofing‌: Mimicking a certified device's hardware/software profile.
## 4. ‌KeyBox.xml‌: Contains cryptographic keys for device attestation.
# If you'd like to support me:

<a href="https://www.buymeacoffee.com/daboynb" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="41" width="174"></a>

This is a rewrite of Playcurl, the old version became outdated as many things have changed. Paradoxically, this is more lightweight and easier to use.

# Support group
https://t.me/playfixnext

# How to Use
- Flash the module. (You must have play integrity fix installed)
- Reboot.
- Check for integity.

# How it Works
- At every boot, the fingerprint (fp) will be pulled using the action.sh script of your pif module.
- Every hour, the updated fingerprint will be downloaded.

# How to configure a different time interval
1) You can set your own time interval by specifying the number of minutes inside the file: 
        `/data/adb/modules/playcurlNEXT/minutes.txt` 
(minimum 1 minute, maximum 1400 minutes)
Reboot to apply.   

# Credits
- [chiteroman/PlayIntegrityFix](https://github.com/chiteroman/PlayIntegrityFix)

- [osm0sis/PlayIntegrityFork](https://github.com/osm0sis/PlayIntegrityFork)
