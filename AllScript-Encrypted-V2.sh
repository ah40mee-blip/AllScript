#!/bin/sh
# Copyright (c) 2026 Eng / Ahmed Abdel-Moati - All-Script Rebuilt From All-Script.txt
P="/usr/script/allscript_progress.txt"; touch "$P"; DONE=$(cat "$P" 2>/dev/null); [ -z "$DONE" ] && DONE=0
# --- Image Detection ---
G() { cat /etc/image-version 2>/dev/null; echo ""; cat /etc/issue 2>/dev/null; echo ""; cat /etc/os-release 2>/dev/null; echo ""; cat /etc/version 2>/dev/null; echo ""; cat /etc/enigma2/settings 2>/dev/null | grep -i image; }
R="$(G)"; A=0; E=0; L=0; B=0; V=0
echo "$R"|grep -qi openatv && A=1; echo "$R"|grep -qi egami && E=1; echo "$R"|grep -qi openpli && L=1; echo "$R"|grep -qi "openbh\|blackhole" && B=1; echo "$R"|grep -qi openvix && V=1
S=0; F=0; [ "$A" = "1" ] || [ "$E" = "1" ] && S=1; [ "$L" = "1" ] || [ "$B" = "1" ] || [ "$V" = "1" ] && F=1
# --- Device Detection: Novaler / Multibox / Vu+ / Others ---
D() { cat /proc/stb/info/model 2>/dev/null; echo ""; cat /proc/stb/info/boxtype 2>/dev/null; echo ""; cat /proc/stb/info/machinename 2>/dev/null; echo ""; cat /proc/stb/info/board 2>/dev/null; echo ""; cat /proc/stb/info/chipset 2>/dev/null; echo ""; cat /proc/stb/info/* 2>/dev/null; echo ""; cat /proc/device-tree/model 2>/dev/null; echo ""; cat /sys/firmware/devicetree/base/model 2>/dev/null; echo ""; cat /etc/hostname 2>/dev/null; }
N=$(D|tr 'A-Z' 'a-z'|tr -d ' _-'); IS=0; echo "$N"|grep -Eq "novaler|multibox|novale|novpro|mbs" && IS=1
echo "$N"|grep -q "vu" && echo "=> Vu+ Detected - Device: $N"
echo "$N"|grep -Eq "novaler|multibox" && echo "=> Novaler Detected - Device: $N"
# --- Block Reboot / Shutdown / init / killall in middle of script ---
mkdir -p /tmp/noreboot; for c in reboot shutdown halt poweroff systemctl busybox init killall; do printf '#!/bin/sh\nexit 0\n' > /tmp/noreboot/$c; chmod 755 /tmp/noreboot/$c; done
O="$PATH"; export PATH="/tmp/noreboot:$PATH"
# --- Wait Internet ---
W() { T=0; while [ $T -lt 40 ]; do ping -c1 -W2 8.8.8.8 >/dev/null 2>&1 || wget -q --no-check-certificate --spider https://raw.githubusercontent.com >/dev/null 2>&1 && return 0; T=$((T+1)); sleep 30; export PATH="/tmp/noreboot:$PATH"; done; return 1; }
# --- Generic Installer ---
I() { NUM="$1"; NAME="$2"; URL="$3"
if [ "$NAME" = "aglare-pli" ] || [ "$NAME" = "aglare-fhd" ]; then Q="$(G)"; echo "$Q"|grep -qi openatv && S=1; echo "$Q"|grep -qi egami && S=1; echo "$Q"|grep -qi openpli && F=1; echo "$Q"|grep -qi "openbh\|blackhole" && F=1; echo "$Q"|grep -qi openvix && F=1; fi
if [ "$NAME" = "novalerStore" ] || [ "$NAME" = "ipaudioplus" ]; then M=$(D|tr 'A-Z' 'a-z'|tr -d ' _-'); echo "$M"|grep -Eq "novaler|multibox|novale|novpro|mbs" && IS=1 || IS=0; fi
if [ "$NAME" = "aglare-pli" ] && [ "$S" = "1" ]; then echo "=> [SKIP] aglare-pli - Image is ATV/Egami"; echo "$NUM" > "$P"; DONE=$NUM; return 0; fi
if [ "$NAME" = "aglare-fhd" ] && [ "$F" = "1" ]; then echo "=> [SKIP] aglare-fhd - Image is PLi/BH/VIX"; echo "$NUM" > "$P"; DONE=$NUM; return 0; fi
if [ "$NAME" = "novalerStore" ] && [ "$IS" = "0" ]; then echo "[SKIP] novalerStore - Not Novaler - Device: $N"; echo "$NUM" > "$P"; DONE=$NUM; return 0; fi
if [ "$NAME" = "ipaudioplus" ] && [ "$IS" = "0" ]; then echo "[SKIP] ipaudioplus - Not Novaler - Device: $N"; echo "$NUM" > "$P"; DONE=$NUM; return 0; fi
if [ "$NUM" -le "$DONE" ]; then return 0; fi
echo "== [$NUM] $NAME =="; W; OK=0
for i in 1 2 3 4 5 6 7 8 9 10; do rm -f /tmp/_i.sh; wget --no-check-certificate --tries=3 --timeout=30 "$URL" -O /tmp/_i.sh; if [ -s /tmp/_i.sh ]; then OK=1; break; fi; sleep 15; W; done
if [ "$OK" = "0" ]; then echo "$((NUM-1))" > "$P"; return 0; fi
sed -i -e '/^[[:space:]]*reboot/d' -e '/reboot[[:space:]]*$/d' -e 's/;[[:space:]]*reboot/; echo [BLOCKED]/g' -e 's/&&[[:space:]]*reboot/ \&\& echo [BLOCKED]/g' -e '/shutdown.*-r/d' -e '/systemctl.*reboot/d' -e '/systemctl.*poweroff/d' -e '/init[[:space:]]*6/d' -e '/init[[:space:]]*4/d' -e '/init[[:space:]]*3/d' -e '/killall.*enigma2/d' /tmp/_i.sh
if [ "$NAME" = "FootOnsat" ]; then sed -i -e 's/^[[:space:]]*read[[:space:]].*/choice=1; REPLY=1; install_method=1 # AUTO/' -e 's/read -p.*/choice=1; REPLY=1 # AUTO/' /tmp/_i.sh; ( sleep 1; echo "1"; sleep 1; echo "1"; sleep 1; echo "1"; sleep 1; echo "1"; sleep 1; echo "1" ) | PATH="/tmp/noreboot:$PATH" /bin/sh /tmp/_i.sh; else PATH="/tmp/noreboot:$PATH" /bin/sh /tmp/_i.sh; fi
echo "$NUM" > "$P"; DONE=$NUM; rm -f /tmp/_i.sh; sleep 2; export PATH="/tmp/noreboot:$PATH"; }
# --- SimplySports: Independent flag, NOT using DONE - Fix SKIP bug for 18/19 ---
J() { if [ -f "/usr/script/simply_done.txt" ]; then return 0; fi; echo "== [17] SimplySports =="; W; cd /usr/lib/enigma2/python/Plugins/Extensions || return 0; rm -rf SimplySports; OK=0; for i in 1 2 3 4 5 6 7 8 9 10; do rm -f SimplySports.zip; wget --no-check-certificate --tries=3 --timeout=30 https://github.com/Ahmed-Mohammed-Abbas/SimplySports/archive/refs/heads/main.zip -O SimplySports.zip; if [ -s SimplySports.zip ]; then OK=1; break; fi; sleep 15; W; done; if [ "$OK" = "0" ]; then return 0; fi; unzip -o SimplySports.zip; mv SimplySports-main SimplySports; rm -f SimplySports.zip; echo "done" > "/usr/script/simply_done.txt"; }
# --- AutoSub: Original command had init 4 / init 3 - BLOCKED, no restart here ---
K() { if [ "35" -le "$DONE" ]; then return 0; fi; echo "== [35] AutoSub =="; W; OK=0; for i in 1 2 3 4 5 6 7 8 9 10; do rm -f /tmp/AutoSub.tar.gz; wget -q --no-check-certificate --tries=3 --timeout=30 -O /tmp/AutoSub.tar.gz https://raw.githubusercontent.com/HBK2010/AutoSub/main/AutoSub.tar.gz; if [ -s /tmp/AutoSub.tar.gz ]; then OK=1; break; fi; sleep 15; W; done; if [ "$OK" = "0" ]; then echo "34" > "$P"; return 0; fi; tar xzf /tmp/AutoSub.tar.gz -C /usr/lib/enigma2/python/Plugins/Extensions; rm -f /tmp/AutoSub.tar.gz; echo "35" > "$P"; DONE=35; }
# --- SubExtractorLite: installer.sh first, then IPK fallback by Python/Arch ---
Z() { if [ "36" -le "$DONE" ]; then return 0; fi; echo "== [36] SubExtractorLite =="; W; if ! command -v bash >/dev/null 2>&1; then opkg update; opkg install bash; sleep 2; fi; rm -f /tmp/_s.sh /tmp/subext.log; wget --no-check-certificate --tries=3 --timeout=30 https://raw.githubusercontent.com/Arian7s/SubExtractorLite/main/installer.sh -O /tmp/_s.sh; if [ -s /tmp/_s.sh ]; then chmod +x /tmp/_s.sh; export PATH="$O"; if command -v bash >/dev/null 2>&1; then bash /tmp/_s.sh 2>&1 | tee /tmp/subext.log; else /bin/sh /tmp/_s.sh 2>&1 | tee /tmp/subext.log; fi; sleep 3; export PATH="/tmp/noreboot:$PATH"; fi; if opkg list-installed 2>/dev/null | grep -qi subextractor || ls /usr/lib/enigma2/python/Plugins/Extensions/ | grep -qi SubExtractor; then echo "36" > "$P"; DONE=36; rm -f /tmp/_s.sh; return 0; fi; VER=$(python3 -c "import urllib.request,json; print([x['name'] for x in json.loads(urllib.request.urlopen('https://api.github.com/repos/Arian7s/SubExtractorLite/contents/', timeout=20).read()) if x['name'].startswith('v')][-1])" 2>/dev/null); if [ -z "$VER" ]; then VER=$(wget -qO- https://api.github.com/repos/Arian7s/SubExtractorLite/contents/ 2>/dev/null | grep '"name": "v' | tail -n 1 | sed 's/.*\"v/v/;s/\".*//'); VER="v$VER"; fi; if [ -z "$VER" ] || [ "$VER" = "v" ]; then echo "35" > "$P"; return 0; fi; ARCH=$(uname -m); case "$ARCH" in aarch64) AD="aarch64" ;; armv7l|arm*) AD="arm" ;; mips*) AD="mipsel" ;; *) AD="$ARCH" ;; esac; opkg update; opkg install python3-pillow; for PY in 3.14 3.13 3.12; do IPK="enigma2-plugin-extensions-subextractorlite_${VER#v}_${ARCH}_py${PY}.ipk"; URL="https://raw.githubusercontent.com/Arian7s/SubExtractorLite/main/${VER}/py${PY}/${AD}/${IPK}"; rm -f /tmp/$IPK; wget --no-check-certificate --tries=3 --timeout=30 "$URL" -O /tmp/$IPK; if [ -s /tmp/$IPK ]; then opkg install --force-reinstall --force-overwrite --force-downgrade /tmp/$IPK 2>&1 | tee -a /tmp/subext.log; sleep 2; if opkg list-installed 2>/dev/null | grep -qi subextractor || ls /usr/lib/enigma2/python/Plugins/Extensions/ | grep -qi SubExtractor; then echo "36" > "$P"; DONE=36; rm -f /tmp/$IPK /tmp/_s.sh; export PATH="/tmp/noreboot:$PATH"; return 0; fi; fi; done; echo "35" > "$P"; }
# --- Order EXACTLY as All-Script.txt ---
I "1" "update-all-python" "https://raw.githubusercontent.com/emil237/updates-enigma/main/update-all-python.sh"
opkg install wget
I "2" "MyStreamer" "https://raw.githubusercontent.com/popking159/MyStreamer/refs/heads/main/myinstaller.sh"
I "3" "novalerdownloader" "https://raw.githubusercontent.com/popking159/novalerdownloader/refs/heads/main/myinstaller.sh"
I "4" "AJPanel" "http://dreambox4u.com/emilnabil237/plugins/ajpanel/installer.sh"
I "5" "SubsSupportPro" "https://github.com/popking159/SubsSupportPro/raw/refs/heads/main/myinstaller.sh"
I "6" "internet-speedtest" "https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/internet-speedtest.sh"
I "7" "EmuInstaller" "https://raw.githubusercontent.com/popking159/EmuInstaller/refs/heads/main/myinstaller.sh"
I "8" "IPAudioPro" "https://raw.githubusercontent.com/zKhadiri/IPAudioPro-Releases-/main/installer.sh"
I "9" "Epg-Grabber" "https://dreambox4u.com/emilnabil237/plugins/Epg-Grabber/installer.sh"
I "10" "EmilRemovePackage" "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EmilRemovePackage/EmilRemovePackage.sh"
I "11" "customchannelselection" "https://raw.githubusercontent.com/popking159/customchannelselection/refs/heads/main/myinstaller.sh"
I "12" "crashlogviewer" "https://dreambox4u.com/emilnabil237/plugins/crashlogviewer/crashlogviewer_1.9.sh"
I "13" "cacheflush" "https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/cacheflush/cacheflush.sh"
I "14" "bitrate" "https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/bitrate/bitrate.sh"
I "15" "AutoZap-Recovery" "https://raw.githubusercontent.com/HBK2010/-AutoZap-Recovery-by-Ahmad-Alamri/main/installer.sh"
I "16" "ArabicSavior" "http://dreambox4u.com/emilnabil237/plugins/ArabicSavior/installer.sh"
J
I "18" "buttonpatcher" "https://raw.githubusercontent.com/popking159/buttonpatcher/refs/heads/main/myinstaller.sh"
I "19" "FootOnsat" "https://raw.githubusercontent.com/fairbird/FootOnsat/main/Download/install.sh"
I "20" "LukaTV" "https://raw.githubusercontent.com/popking159/LukaTV/refs/heads/main/myinstaller.sh"
I "21" "novalerStore" "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/novaler/novalerStore.sh"
I "22" "ipaudioplus" "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/novaler/ipaudioplus.sh"
I "23" "aglare-pli" "https://github.com/emilnabil/aglare/raw/refs/heads/main/skins-aglare-fhd-pli.sh"
I "24" "aglare-fhd" "https://github.com/emilnabil/aglare/raw/refs/heads/main/skins-aglare-fhd.sh"
I "25" "RaedQuickSignal" "https://raw.githubusercontent.com/fairbird/RaedQuickSignal/main/installer.sh"
I "26" "NewVirtualKeyBoard" "https://raw.githubusercontent.com/fairbird/NewVirtualKeyBoard/main/installer.sh"
I "27" "AutoBiss" "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/AutoBiss/AutoBiss.sh"
I "28" "auto-dcw-key-add" "https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/auto-dcw-key-add/auto-dcw-key-add.sh"
I "29" "FuryBiss" "https://raw.githubusercontent.com/islam-2412/FuryBiss/refs/heads/main/fury/installer.sh"
I "30" "hisnmuslim" "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/hisnmuslim/hisnmuslim.sh"
I "31" "netusagepro" "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/netusagepro/netusagepro.sh"
I "32" "quran" "https://raw.githubusercontent.com/emil237/quran/main/installer.sh"
I "33" "xtraevent" "https://github.com/popking159/xtraeventplugin/raw/main/xtraevent-install.sh"
I "34" "myhits" "https://raw.githubusercontent.com/popking159/myhits/refs/heads/main/myinstaller.sh"
K
Z
clear; echo "=========================================================="; echo "   All-Script By Eng Ahmed Abdel-Moati"; echo "   Copyright (c) 2026 Eng / Ahmed Abdel-Moati"; echo "=========================================================="; echo ""; echo "   Select Channel List to Install:"; echo ""; echo "----------------------------------------------------------"; echo "   [ 1 ]  Emil Nabil"; echo "          Full List - Main List"; echo ""; echo "   [ 2 ]  Hazem Wahba"; echo "          Full List"; echo ""; echo "   [ 3 ]  Khaled"; echo "          Full List"; echo ""; echo "   [ 4 ]  Mnasr"; echo "          Full List"; echo "----------------------------------------------------------"; echo "   [ 0 ]  Skip"; echo "          Continue Without Channel List"; echo "----------------------------------------------------------"; echo ""; echo "   Note: Choose one number only from 0 to 4"
while true; do printf "   Enter Number Here and Press Enter  [ 0-4 ] : "; read CH; case "$CH" in 1) CH_NAME="Emil Nabil"; CH_URL="https://raw.githubusercontent.com/emilnabil/channel-emil-nabil/main/installer.sh"; break ;; 2) CH_NAME="Hazem Wahba"; CH_URL="https://raw.githubusercontent.com/emilnabil/channel-hazem-wahba/main/installer.sh"; break ;; 3) CH_NAME="Khaled"; CH_URL="https://raw.githubusercontent.com/emilnabil/channel-khaled/main/installer.sh"; break ;; 4) CH_NAME="Mnasr"; CH_URL="https://raw.githubusercontent.com/emilnabil/channel-mnasr/main/installer.sh"; break ;; 0) CH_NAME="Skip"; break ;; *) echo ""; echo "   !!! Wrong Number - Enter Number From 0 to 4 Only !!!"; echo ""; continue ;; esac; done
if [ "$CH" = "0" ]; then echo ""; echo "   Skipped - Continue Without Channel List"; else echo ""; echo "   You Selected : $CH_NAME"; printf "   Are You Sure ? Type y to Confirm or n to Cancel [ y/n ] : "; read CONFIRM; if [ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "Y" ] || [ "$CONFIRM" = "1" ]; then echo ""; echo "   Downloading Channel List ... Please Wait ..."; wget -q --no-check-certificate "$CH_URL" -O - | /bin/sh; echo ""; echo "   Done - Channel List Installed Successfully"; else echo ""; echo "   Cancelled - Continue Without Channel List"; fi; fi
echo ""; echo "Copyright (c) 2026 Eng / Ahmed Abdel-Moati - ALL DONE - REAL restart now"; export PATH="$O"; rm -rf /tmp/noreboot /tmp/_i.sh; rm -f "$P"; sleep 2; reboot; exit 0
