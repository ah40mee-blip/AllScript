#!/bin/sh
# Copyright (c) 2026 Eng / Ahmed Abdel-Moati - All Rights Reserved
# All-Script By Eng Ahmed Abdel-Moati - 37 Plugins - FINAL
clear; echo "Copyright (c) 2026 Eng / Ahmed Abdel-Moati - All-Script 37 Plugins"; sleep 2
P="/usr/script/allscript_progress.txt"; touch "$P"; DONE=$(cat "$P" 2>/dev/null); [ -z "$DONE" ] && DONE=0
get_image_raw() { cat /etc/image-version 2>/dev/null; echo ""; cat /etc/issue 2>/dev/null; echo ""; cat /etc/os-release 2>/dev/null; echo ""; cat /etc/version 2>/dev/null; echo ""; ls /etc/*atv* /etc/*egami* /etc/*pli* /etc/*vix* /etc/*bh* 2>/dev/null; echo ""; cat /etc/enigma2/settings 2>/dev/null | grep -i image; }
IMAGE_RAW="$(get_image_raw)"
echo "Image Raw: $IMAGE_RAW"
IS_ATV=0; IS_EGAMI=0; IS_PLI=0; IS_BH=0; IS_VIX=0
echo "$IMAGE_RAW" | grep -qi "openatv" && IS_ATV=1
echo "$IMAGE_RAW" | grep -qi "egami" && IS_EGAMI=1
echo "$IMAGE_RAW" | grep -qi "openpli" && IS_PLI=1
echo "$IMAGE_RAW" | grep -qi "openbh\|blackhole" && IS_BH=1
echo "$IMAGE_RAW" | grep -qi "openvix" && IS_VIX=1
echo "Detect: ATV=$IS_ATV EGAMI=$IS_EGAMI PLI=$IS_PLI BH=$IS_BH VIX=$IS_VIX"
SKIP_PLI=0; SKIP_FHD=0
if [ "$IS_ATV" = "1" ] || [ "$IS_EGAMI" = "1" ]; then SKIP_PLI=1; echo "=> ATV/Egami DETECTED - WILL SKIP aglare-pli"; fi
if [ "$IS_PLI" = "1" ] || [ "$IS_BH" = "1" ] || [ "$IS_VIX" = "1" ]; then SKIP_FHD=1; echo "=> PLi/BH/ViX DETECTED - WILL SKIP aglare-fhd"; fi
echo "SKIP_PLI=$SKIP_PLI SKIP_FHD=$SKIP_FHD"
get_device_raw() { cat /proc/stb/info/model 2>/dev/null; echo ""; cat /proc/stb/info/boxtype 2>/dev/null; echo ""; cat /proc/stb/info/machinename 2>/dev/null; echo ""; cat /proc/stb/info/chipset 2>/dev/null; echo ""; cat /proc/stb/info/board 2>/dev/null; echo ""; cat /proc/stb/info/* 2>/dev/null; echo ""; cat /proc/device-tree/model 2>/dev/null; echo ""; cat /sys/firmware/devicetree/base/model 2>/dev/null; echo ""; cat /etc/hostname 2>/dev/null; echo ""; ls /etc/*novaler* 2>/dev/null; }
DEVICE_RAW="$(get_device_raw)"
echo "Device Raw: $DEVICE_RAW"
DEV_NORM=$(echo "$DEVICE_RAW" | tr 'A-Z' 'a-z' | tr -d ' _-')
echo "Device Norm: $DEV_NORM"
IS_NOVALER=0
if echo "$DEV_NORM" | grep -q "novaler"; then IS_NOVALER=1; fi
if [ "$IS_NOVALER" = "1" ]; then echo "=> Novaler DETECTED - WILL INSTALL novalerStore + ipaudioplus"; echo "$DEV_NORM" | grep -q "novaler4kpro" && echo "=> Model: Novaler 4K Pro"; echo "$DEV_NORM" | grep -q "novaler4kse" && echo "=> Model: Novaler 4K SE"; echo "$DEV_NORM" | grep -q "novaler4k" && echo "=> Model: Novaler 4K"; else echo "=> NOT Novaler DETECTED - WILL SKIP novalerStore + ipaudioplus"; fi
echo "IS_NOVALER=$IS_NOVALER"
mkdir -p /tmp/noreboot
for c in reboot shutdown halt poweroff systemctl busybox; do printf '#!/bin/sh\nexit 0\n' > /tmp/noreboot/$c; chmod 755 /tmp/noreboot/$c; done
printf '#!/bin/sh\nexit 0\n' > /tmp/noreboot/init; chmod 755 /tmp/noreboot/init
printf '#!/bin/sh\nexit 0\n' > /tmp/noreboot/killall; chmod 755 /tmp/noreboot/killall
ORIG_PATH="$PATH"; export PATH="/tmp/noreboot:$PATH"
wait_for_net() { T=0; while [ $T -lt 40 ]; do ping -c1 -W2 8.8.8.8 >/dev/null 2>&1 || wget -q --no-check-certificate --spider https://raw.githubusercontent.com >/dev/null 2>&1 && return 0; T=$((T+1)); sleep 30; export PATH="/tmp/noreboot:$PATH"; done; return 1; }
install_one() { NUM="$1"; NAME="$2"; URL="$3"
if [ "$NAME" = "aglare-pli" ] || [ "$NAME" = "aglare-fhd" ]; then
  LIVE_RAW="$(get_image_raw)"
  if echo "$LIVE_RAW" | grep -qi "openatv"; then SKIP_PLI=1; fi
  if echo "$LIVE_RAW" | grep -qi "egami"; then SKIP_PLI=1; fi
  if echo "$LIVE_RAW" | grep -qi "openpli"; then SKIP_FHD=1; fi
  if echo "$LIVE_RAW" | grep -qi "openbh\|blackhole"; then SKIP_FHD=1; fi
  if echo "$LIVE_RAW" | grep -qi "openvix"; then SKIP_FHD=1; fi
  echo "[LIVE CHECK] $NAME - SKIP_PLI=$SKIP_PLI SKIP_FHD=$SKIP_FHD"
fi
if [ "$NAME" = "novalerStore" ] || [ "$NAME" = "ipaudioplus" ]; then
  LIVE_DEV_NORM=$(get_device_raw | tr 'A-Z' 'a-z' | tr -d ' _-')
  echo "$LIVE_DEV_NORM" | grep -q "novaler" && IS_NOVALER=1 || IS_NOVALER=0
  echo "[LIVE CHECK] $NAME - IS_NOVALER=$IS_NOVALER"
fi
if [ "$NAME" = "aglare-pli" ] && [ "$SKIP_PLI" = "1" ]; then echo "[SKIP $NUM] $NAME - ATV/Egami - SKIPPED OK"; echo "$NUM" > "$P"; DONE=$NUM; return 0; fi
if [ "$NAME" = "aglare-fhd" ] && [ "$SKIP_FHD" = "1" ]; then echo "[SKIP $NUM] $NAME - PLi/BH/ViX - SKIPPED OK"; echo "$NUM" > "$P"; DONE=$NUM; return 0; fi
if [ "$NAME" = "novalerStore" ] && [ "$IS_NOVALER" = "0" ]; then echo "[SKIP $NUM] $NAME - Not Novaler"; echo "$NUM" > "$P"; DONE=$NUM; return 0; fi
if [ "$NAME" = "ipaudioplus" ] && [ "$IS_NOVALER" = "0" ]; then echo "[SKIP $NUM] $NAME - Not Novaler"; echo "$NUM" > "$P"; DONE=$NUM; return 0; fi
if [ "$NUM" -le "$DONE" ]; then echo "[SKIP $NUM] $NAME done"; return 0; fi
echo "== [$NUM] $NAME =="; wait_for_net; OK=0
for i in 1 2 3 4 5 6 7 8 9 10; do rm -f /tmp/_i.sh; wget --no-check-certificate --tries=3 --timeout=30 "$URL" -O /tmp/_i.sh; if [ -s /tmp/_i.sh ]; then OK=1; break; fi; echo "[RETRY] $NAME $i/10"; sleep 15; wait_for_net; done
if [ "$OK" = "0" ]; then echo "[FAIL] $NAME"; echo "$((NUM-1))" > "$P"; return 0; fi
sed -i -e '/^[[:space:]]*reboot/d' -e '/reboot[[:space:]]*$/d' -e 's/;[[:space:]]*reboot/; echo [BLOCKED]/g' -e 's/&&[[:space:]]*reboot/ \&\& echo [BLOCKED]/g' -e '/shutdown.*-r/d' -e '/systemctl.*reboot/d' -e '/systemctl.*poweroff/d' -e '/init[[:space:]]*6/d' -e '/init[[:space:]]*4/d' -e '/init[[:space:]]*3/d' -e '/killall.*enigma2/d' /tmp/_i.sh
if [ "$NAME" = "FootOnsat" ]; then echo "[AUTO] FootOnsat=1"; sed -i -e 's/^[[:space:]]*read[[:space:]].*/choice=1; REPLY=1; install_method=1 # AUTO/' -e 's/read -p.*/choice=1; REPLY=1 # AUTO/' /tmp/_i.sh; ( sleep 1; echo "1"; sleep 1; echo "1"; sleep 1; echo "1"; sleep 1; echo "1"; sleep 1; echo "1" ) | PATH="/tmp/noreboot:$PATH" /bin/sh /tmp/_i.sh; else PATH="/tmp/noreboot:$PATH" /bin/sh /tmp/_i.sh; fi
echo "Done $NAME"; echo "$NUM" > "$P"; DONE=$NUM; rm -f /tmp/_i.sh; sleep 2; export PATH="/tmp/noreboot:$PATH"; }
install_19() { if [ "18" -le "$DONE" ]; then return 0; fi; echo "== [18] SimplySports NO killall =="; wait_for_net; cd /usr/lib/enigma2/python/Plugins/Extensions || return 0; rm -rf SimplySports; OK=0; for i in 1 2 3 4 5 6 7 8 9 10; do rm -f SimplySports.zip; wget --no-check-certificate --tries=3 --timeout=30 https://github.com/Ahmed-Mohammed-Abbas/SimplySports/archive/refs/heads/main.zip -O SimplySports.zip; if [ -s SimplySports.zip ]; then OK=1; break; fi; sleep 15; wait_for_net; done; if [ "$OK" = "0" ]; then echo "[FAIL] SimplySports"; echo "17" > "$P"; return 0; fi; unzip -o SimplySports.zip; mv SimplySports-main SimplySports; rm -f SimplySports.zip; echo "18" > "$P"; DONE=18; export PATH="/tmp/noreboot:$PATH"; }
install_autosub() { if [ "36" -le "$DONE" ]; then return 0; fi; echo "== [36] AutoSub NO reboot =="; wait_for_net; OK=0; for i in 1 2 3 4 5 6 7 8 9 10; do rm -f /tmp/AutoSub.tar.gz; wget -q --no-check-certificate --tries=3 --timeout=30 -O /tmp/AutoSub.tar.gz https://raw.githubusercontent.com/HBK2010/AutoSub/main/AutoSub.tar.gz; if [ -s /tmp/AutoSub.tar.gz ]; then OK=1; break; fi; sleep 15; wait_for_net; done; if [ "$OK" = "0" ]; then echo "[FAIL] AutoSub"; echo "35" > "$P"; return 0; fi; tar xzf /tmp/AutoSub.tar.gz -C /usr/lib/enigma2/python/Plugins/Extensions; rm -f /tmp/AutoSub.tar.gz; echo "[BLOCKED] init skipped"; echo "36" > "$P"; DONE=36; }
install_last() { if [ "37" -le "$DONE" ]; then echo "[SKIP 37] SubExtractorLite done"; return 0; fi; echo "== [37] SubExtractorLite - PYTHON 3.14 FIX - TRY 3.14/3.13/3.12 =="; echo "PYTHON: $(python3 --version 2>&1) - ARCH: $(uname -m)"; wait_for_net; if ! command -v bash >/dev/null 2>&1; then echo "[INFO] No bash - installing..."; opkg update; opkg install bash; sleep 2; fi; echo "BASH: $(which bash 2>&1)"; echo "[STEP 1] Trying official installer..."; rm -f /tmp/_s.sh /tmp/subext.log; wget --no-check-certificate --tries=3 --timeout=30 https://raw.githubusercontent.com/Arian7s/SubExtractorLite/main/installer.sh -O /tmp/_s.sh; if [ -s /tmp/_s.sh ]; then chmod +x /tmp/_s.sh; export PATH="$ORIG_PATH"; if command -v bash >/dev/null 2>&1; then bash /tmp/_s.sh 2>&1 | tee /tmp/subext.log; else /bin/sh /tmp/_s.sh 2>&1 | tee /tmp/subext.log; fi; sleep 3; export PATH="/tmp/noreboot:$PATH"; fi; if opkg list-installed 2>/dev/null | grep -qi subextractor || ls /usr/lib/enigma2/python/Plugins/Extensions/ | grep -qi SubExtractor; then echo "[OK] SubExtractorLite Installed via official installer"; echo "37" > "$P"; DONE=37; rm -f /tmp/_s.sh; return 0; fi; echo "[WARN] Official installer did not install - trying manual IPK fallback..."; cat /tmp/subext.log 2>/dev/null | tail -n 30; VER=$(python3 -c "import urllib.request,json; print([x['name'] for x in json.loads(urllib.request.urlopen('https://api.github.com/repos/Arian7s/SubExtractorLite/contents/', timeout=20).read()) if x['name'].startswith('v')][-1])" 2>/dev/null); if [ -z "$VER" ]; then VER=$(wget -qO- https://api.github.com/repos/Arian7s/SubExtractorLite/contents/ 2>/dev/null | grep '"name": "v' | tail -n 1 | sed 's/.*\"v/v/;s/\".*//'); VER="v$VER"; fi; echo "Latest version detected: $VER"; if [ -z "$VER" ] || [ "$VER" = "v" ]; then echo "[FAIL] Cannot get version from API"; echo "36" > "$P"; return 0; fi; ARCH=$(uname -m); case "$ARCH" in aarch64) ARCH_DIR="aarch64" ;; armv7l|arm*) ARCH_DIR="arm" ;; mips*) ARCH_DIR="mipsel" ;; *) ARCH_DIR="$ARCH" ;; esac; echo "ARCH_DIR: $ARCH_DIR"; opkg update; opkg install python3-pillow; for PY in 3.14 3.13 3.12; do IPK="enigma2-plugin-extensions-subextractorlite_${VER#v}_${ARCH}_py${PY}.ipk"; URL="https://raw.githubusercontent.com/Arian7s/SubExtractorLite/main/${VER}/py${PY}/${ARCH_DIR}/${IPK}"; echo "[TRY] PY=$PY - $IPK"; echo "URL: $URL"; rm -f /tmp/$IPK; wget --no-check-certificate --tries=3 --timeout=30 "$URL" -O /tmp/$IPK; if [ -s /tmp/$IPK ]; then echo "Downloaded: $(wc -c < /tmp/$IPK) bytes - installing..."; opkg install --force-reinstall --force-overwrite --force-downgrade /tmp/$IPK 2>&1 | tee -a /tmp/subext.log; sleep 2; if opkg list-installed 2>/dev/null | grep -qi subextractor || ls /usr/lib/enigma2/python/Plugins/Extensions/ | grep -qi SubExtractor; then echo "[OK] SubExtractorLite Installed via manual IPK py$PY"; echo "37" > "$P"; DONE=37; rm -f /tmp/$IPK /tmp/_s.sh; export PATH="/tmp/noreboot:$PATH"; return 0; else echo "[WARN] IPK py$PY downloaded but not installed - trying next PY"; fi; else echo "[SKIP] py$PY IPK not found (404) - trying next"; fi; done; echo "[FAIL] SubExtractorLite Still not found - check /tmp/subext.log"; echo "--- LOG TAIL ---"; tail -n 50 /tmp/subext.log 2>/dev/null; echo "36" > "$P"; export PATH="/tmp/noreboot:$PATH"; }
install_one "1" "update-all-python" "https://raw.githubusercontent.com/emil237/updates-enigma/main/update-all-python.sh"
opkg install wget
install_one "2" "MyStreamer" "https://raw.githubusercontent.com/popking159/MyStreamer/refs/heads/main/myinstaller.sh"
install_one "3" "novalerdownloader" "https://raw.githubusercontent.com/popking159/novalerdownloader/refs/heads/main/myinstaller.sh"
install_one "4" "AJPanel" "http://dreambox4u.com/emilnabil237/plugins/ajpanel/installer.sh"
install_one "5" "SubsSupportPro" "https://github.com/popking159/SubsSupportPro/raw/refs/heads/main/myinstaller.sh"
install_one "6" "internet-speedtest" "https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/internet-speedtest.sh"
install_one "7" "EmuInstaller" "https://raw.githubusercontent.com/popking159/EmuInstaller/refs/heads/main/myinstaller.sh"
install_one "8" "epgtranslator" "https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/epgtranslator.sh"
install_one "9" "Epg-Grabber" "https://dreambox4u.com/emilnabil237/plugins/Epg-Grabber/installer.sh"
install_one "10" "EmilRemovePackage" "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EmilRemovePackage/EmilRemovePackage.sh"
install_one "11" "customchannelselection" "https://raw.githubusercontent.com/popking159/customchannelselection/refs/heads/main/myinstaller.sh"
install_one "12" "crashlogviewer" "https://dreambox4u.com/emilnabil237/plugins/crashlogviewer/crashlogviewer_1.9.sh"
install_one "13" "cacheflush" "https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/cacheflush/cacheflush.sh"
install_one "14" "bitrate" "https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/bitrate/bitrate.sh"
install_one "15" "AutoZap-Recovery" "https://raw.githubusercontent.com/HBK2010/-AutoZap-Recovery-by-Ahmad-Alamri/main/installer.sh"
install_one "16" "ArabicSavior" "http://dreambox4u.com/emilnabil237/plugins/ArabicSavior/installer.sh"
install_19
install_one "17" "buttonpatcher" "https://raw.githubusercontent.com/popking159/buttonpatcher/refs/heads/main/myinstaller.sh"
install_one "18" "FootOnsat" "https://raw.githubusercontent.com/fairbird/FootOnsat/main/Download/install.sh"
install_one "19" "LukaTV" "https://raw.githubusercontent.com/popking159/LukaTV/refs/heads/main/myinstaller.sh"
install_one "20" "novalerStore" "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/novaler/novalerStore.sh"
install_one "21" "ipaudioplus" "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/novaler/ipaudioplus.sh"
install_one "22" "aglare-pli" "https://github.com/emilnabil/aglare/raw/refs/heads/main/skins-aglare-fhd-pli.sh"
install_one "23" "aglare-fhd" "https://github.com/emilnabil/aglare/raw/refs/heads/main/skins-aglare-fhd.sh"
install_one "24" "RaedQuickSignal" "https://raw.githubusercontent.com/fairbird/RaedQuickSignal/main/installer.sh"
install_one "25" "NewVirtualKeyBoard" "https://raw.githubusercontent.com/fairbird/NewVirtualKeyBoard/main/installer.sh"
install_one "26" "AutoBiss" "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/AutoBiss/AutoBiss.sh"
install_one "27" "auto-dcw-key-add" "https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/auto-dcw-key-add/auto-dcw-key-add.sh"
install_one "28" "FuryBiss" "https://raw.githubusercontent.com/islam-2412/FuryBiss/refs/heads/main/fury/installer.sh"
install_one "29" "hisnmuslim" "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/hisnmuslim/hisnmuslim.sh"
install_one "30" "netusagepro" "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/netusagepro/netusagepro.sh"
install_one "31" "quran" "https://raw.githubusercontent.com/emil237/quran/main/installer.sh"
install_one "32" "xtraevent" "https://github.com/popking159/xtraeventplugin/raw/main/xtraevent-install.sh"
install_one "33" "IPAudioPro" "https://github.com/zKhadiri/IPAudioPro-Releases-/raw/refs/heads/main/installer.sh"
install_one "34" "myhits" "https://raw.githubusercontent.com/popking159/myhits/refs/heads/main/myinstaller.sh"
install_autosub
install_last
clear
echo "=========================================================="
echo "   All-Script By Eng Ahmed Abdel-Moati"
echo "   Copyright (c) 2026 Eng / Ahmed Abdel-Moati"
echo "=========================================================="
echo ""
echo "   Select Channel List to Install:"
echo ""
echo "----------------------------------------------------------"
echo "   [ 1 ]  Emil Nabil"
echo "          Full List - Main List"
echo ""
echo "   [ 2 ]  Hazem Wahba"
echo "          Full List"
echo ""
echo "   [ 3 ]  Khaled"
echo "          Full List"
echo ""
echo "   [ 4 ]  Mnasr"
echo "          Full List"
echo "----------------------------------------------------------"
echo "   [ 0 ]  Skip"
echo "          Continue Without Channel List"
echo "----------------------------------------------------------"
echo ""
echo "   Note: Choose one number only from 0 to 4"
while true; do printf "   Enter Number Here and Press Enter  [ 0-4 ] : "; read CH; case "$CH" in 1) CH_NAME="Emil Nabil"; CH_URL="https://raw.githubusercontent.com/emilnabil/channel-emil-nabil/main/installer.sh"; break ;; 2) CH_NAME="Hazem Wahba"; CH_URL="https://raw.githubusercontent.com/emilnabil/channel-hazem-wahba/main/installer.sh"; break ;; 3) CH_NAME="Khaled"; CH_URL="https://raw.githubusercontent.com/emilnabil/channel-khaled/main/installer.sh"; break ;; 4) CH_NAME="Mnasr"; CH_URL="https://raw.githubusercontent.com/emilnabil/channel-mnasr/main/installer.sh"; break ;; 0) CH_NAME="Skip"; break ;; *) echo ""; echo "   !!! Wrong Number - Enter Number From 0 to 4 Only !!!"; echo ""; continue ;; esac; done
if [ "$CH" = "0" ]; then echo ""; echo "   Skipped - Continue Without Channel List"; else echo ""; echo "   You Selected : $CH_NAME"; printf "   Are You Sure ? Type y to Confirm or n to Cancel [ y/n ] : "; read CONFIRM; if [ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "Y" ] || [ "$CONFIRM" = "1" ]; then echo ""; echo "   Downloading Channel List ... Please Wait ..."; wget -q --no-check-certificate "$CH_URL" -O - | /bin/sh; echo ""; echo "   Done - Channel List Installed Successfully"; else echo ""; echo "   Cancelled - Continue Without Channel List"; fi; fi
echo ""; echo "Copyright (c) 2026 Eng / Ahmed Abdel-Moati - ALL DONE - REAL restart now"; export PATH="$ORIG_PATH"; rm -rf /tmp/noreboot /tmp/_i.sh; rm -f "$P"; sleep 2; reboot; exit 0