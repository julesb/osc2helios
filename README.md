# osc2helios
OSC -> Helios DAC prototype


#### udev rule for pd_helios
```
etc/udev/rules.d$ cat 011_heliosdac.rules
ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="e500", TAG+="uaccess"
```
