setMode -bscan
setCable -port auto
identify
assignFile -p 5 -file mkBridge.bit
program -p 5
quit
