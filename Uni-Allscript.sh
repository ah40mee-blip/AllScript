#!/bin/sh
# Copyright (c) 2026 Eng / Ahmed Abdel-Moati - Universal V2
# Novaler + Vu+ + Dream + Zgemma + Octagon - بدون Novaler Store / IPAudio / Downloader
# aglare حسب الصورة - FootOnsat AUTO 1 - RaedQuickSignal سكيب على غير النوفالير
clear; echo "Copyright (c) 2026 Eng / Ahmed Abdel-Moati - Universal All-Script V2"; sleep 2
P="/usr/script/allscript_progress.txt"; touch "$P"; DONE=$(cat "$P" 2>/dev/null); [ -z "$DONE" ] && DONE=0

# ===== كشف نوع الصورة =====
get_image_raw() { cat /etc/image-version 2>/dev/null; echo ""; cat /etc/issue 2>/dev/null; echo ""; cat /etc/os-release 2>/dev/null; echo ""; cat /etc/version 2>/dev/null; echo ""; ls /etc/*atv* /etc/*egami* /etc/*pli* /etc/*vix* /etc/*bh* 2>/dev/null; }
IMAGE_RAW="$(get_image_raw)"
IS_ATV=0; IS_EGAMI=0; IS_PLI=0; IS_BH=0; IS_VIX=0
echo "$IMAGE_RAW" | grep -qi "openatv" && IS_ATV=1
echo "$IMAGE_RAW" | grep -qi "egami" && IS_EGAMI=1
echo "$IMAGE_RAW" | grep -qi "openpli" && IS_PLI=1
echo "$IMAGE_RAW" | grep -qi "openbh\|blackhole" && IS_BH=1
echo "$IMAGE_RAW" | grep -qi "openvix" && IS_VIX=1

# ===== كشف نوع الجهاز =====
DEV=""; [ -f /proc/stb/info/model ] && DEV="$DEV $(cat /proc/stb/info/model)"; [ -f /proc/stb/info/boxtype ] && DEV="$DEV $(cat /proc/stb/info/boxtype)"; [ -f /etc/hostname ] && DEV="$DEV $(cat /etc/hostname)"; [ -f /proc/stb/info/chipset ] && DEV="$DEV $(cat /proc/stb/info/chipset)"; DEV=$(echo "$DEV"|tr 'A-Z' 'a-z'); echo "Device Raw: $DEV"
IS_NOVALER=0; IS_VU=0; IS_DREAM=0; IS_ZGEMMA=0; IS_OCTAGON=0; IS_NON_NOVALER=0
echo "$DEV" | grep -q "novaler" && IS_NOVALER=1
echo "$DEV" | grep -q "vu" && IS_VU=1
echo "$DEV" | grep -q "dream\|dm520\|dm525\|dm900\|dm920\|dm800\|dm820\|dm7080" && IS_DREAM=1
echo "$DEV" | grep -q "zgemma\|h7\|h9\|h11\|h10\|i55" && IS_ZGEMMA=1
echo "$DEV" | grep -q "octagon\|sf8008\|sf4008\|sx88\|sx888" && IS_OCTAGON=1
if [ "$IS_NOVALER" = "0" ]; then IS_NON_NOVALER=1; fi
echo "Detect: NOVALER=$IS_NOVALER VU=$IS_VU DREAM=$IS_DREAM ZGEMMA=$IS_ZGEMMA OCTAGON=$IS_OCTAGON NON_NOVALER=$IS_NON_NOVALER"
echo "Image: ATV=$IS_ATV EGAMI=$IS_EGAMI PLI=$IS_PLI BH=$IS_BH VIX=$IS_VIX"
if [ "$IS_NOVALER" = "1" ]; then echo "=> Novaler - FULL INSTALL"; fi
if [ "$IS_VU" = "1" ]; then echo "=> Vu+ DETECTED - SAFE MODE ON"; fi
if [ "$IS_DREAM" = "1" ]; then echo "=> Dreambox DETECTED - SAFE MODE ON"; fi
if [ "$IS_ZGEMMA" = "1" ]; then echo "=> Zgemma DETECTED - SAFE MODE ON"; fi
if [ "$IS_OCTAGON" = "1" ]; then echo "=> Octagon DETECTED - SAFE MODE ON"; fi

# ===== منع الريستارت =====
mkdir -p /tmp/noreboot
for c in reboot shutdown halt poweroff systemctl busybox; do printf '#!/bin/sh\nexit 0\n' > /tmp/noreboot/$c; chmod 755 /tmp/noreboot/$c; done
printf '#!/bin/sh\nexit 0\n' > /tmp/noreboot/init; chmod 755 /tmp/noreboot/init
printf '#!/bin/sh\nexit 0\n' > /tmp/noreboot/killall; chmod 755 /tmp/noreboot/killall
ORIG_PATH="$PATH"; export PATH="/tmp/noreboot:$PATH"
wait_for_net() { T=0; while [ $T -lt 40 ]; do ping -c1 -W2 8.8.8.8 >/dev/null 2>&1 || wget -q --no-check-certificate --spider https://raw.githubusercontent.com >/dev/null 2>&1 && return 0; T=$((T+1)); sleep 30; export PATH="/tmp/noreboot:$PATH"; done; return 1; }

# ===== قواعد السكيب =====
SKIP_PLI=0; SKIP_FHD=0
if [ "$IS_ATV" = "1" ] || [ "$IS_EGAMI" = "1" ]; then SKIP_PLI=1; fi
if [ "$IS_PLI" = "1" ] || [ "$IS_BH" = "1" ] || [ "$IS_VIX" = "1" ]; then SKIP_FHD=1; fi
if [ "$IS_VIX" = "1" ]; then SKIP_PLI=1; SKIP_FHD=1; fi

install_one() { NUM="$1"; NAME="$2"; URL="$3"
if [ "$NAME" = "aglare-pli" ] || [ "$NAME" = "aglare-fhd" ]; then
  LIVE_RAW="$(get_image_raw)"
  echo "$LIVE_RAW" | grep -qi "openatv" && SKIP_PLI=1
  echo "$LIVE_RAW" | grep -qi "egami" && SKIP_PLI=1
  echo "$LIVE_RAW" | grep -qi "openpli" && SKIP_FHD=1
  echo "$LIVE_RAW" | grep -qi "openbh\|blackhole" && SKIP_FHD=1
  echo "$LIVE_RAW" | grep -qi "openvix" && SKIP_FHD=1
fi
# --- قاعدة الأجهزة غير النوفالير : RaedQuickSignal بس ---
if [ "$IS_NON_NOVALER" = "1" ]; then
  case "$NAME" in
    RaedQuickSignal)
      echo "[SKIP $NUM] $NAME - Not Novaler ($DEV) - SAFE SKIP"
      echo "$NUM" > "$P"; DONE=$NUM; return 0
    ;;
  esac
fi
# --- قاعدة السكينات حسب الصورة ---
if [ "$NAME" = "aglare-pli" ] && [ "$SKIP_PLI" = "1" ]; then echo "[SKIP $NUM] $NAME - Wrong Image"; echo "$NUM" > "$P"; DONE=$NUM; return 0; fi
if [ "$NAME" = "aglare-fhd" ] && [ "$SKIP_FHD" = "1" ]; then echo "[SKIP $NUM] $NAME - Wrong Image"; echo "$NUM" > "$P"; DONE=$NUM; return 0; fi
if [ "$NUM" -le "$DONE" ]; then echo "[SKIP $NUM] $NAME done"; return 0; fi
echo "== [$NUM] $NAME =="; wait_for_net; OK=0
for i in 1 2 3 4 5 6 7 8 9 10; do rm -f /tmp/_i.sh; wget --no-check-certificate --tries=3 --timeout=30 "$URL" -O /tmp/_i.sh; if [ -s /tmp/_i.sh ]; then OK=1; break; fi; echo "[RETRY] $NAME $i/10"; sleep 15; wait_for_net; done
if [ "$OK" = "0" ]; then echo "[FAIL] $NAME"; echo "$((NUM-1))" > "$P"; return 0; fi
sed -i -e '/^[[:space:]]*reboot/d' -e '/reboot[[:space:]]*$/d' -e 's/;[[:space:]]*reboot/; echo [BLOCKED]/g' -e 's/&&[[:space:]]*reboot/ \&\& echo [BLOCKED]/g' -e '/shutdown.*-r/d' -e '/systemctl.*reboot/d' -e '/systemctl.*poweroff/d' -e '/init[[:space:]]*6/d' -e '/init[[:space:]]*4/d' -e '/init[[:space:]]*3/d' -e '/killall.*enigma2/d' /tmp/_i.sh
if [ "$NAME" = "FootOnsat" ]; then echo "[AUTO] FootOnsat=1"; sed -i -e 's/^[[:space:]]*read[[:space:]].*/choice=1; REPLY=1; install_method=1 # AUTO/' -e 's/read -p.*/choice=1; REPLY=1 # AUTO/' /tmp/_i.sh; ( sleep 1; echo "1"; sleep 1; echo "1"; sleep 1; echo "1"; sleep 1; echo "1"; sleep 1; echo "1" ) | PATH="/tmp/noreboot:$PATH" /bin/sh /tmp/_i.sh; else PATH="/tmp/noreboot:$PATH" /bin/sh /tmp/_i.sh; fi
echo "Done $NAME"; echo "$NUM" > "$P"; DONE=$NUM; rm -f /tmp/_i.sh; sleep 2; export PATH="/tmp/noreboot:$PATH"; }

install_19() { if [ "18" -le "$DONE" ]; then return 0; fi; echo "== [18] SimplySports NO killall =="; wait_for_net; cd /usr/lib/enigma2/python/Plugins/Extensions || return 0; rm -rf SimplySports; OK=0; for i in 1 2 3 4 5 6 7 8 9 10; do rm -f SimplySports.zip; wget --no-check-certificate --tries=3 --timeout=30 https://github.com/Ahmed-Mohammed-Abbas/SimplySports/archive/refs/heads/main.zip -O SimplySports.zip; if [ -s SimplySports.zip ]; then OK=1; break; fi; sleep 15; wait_for_net; done; if [ "$OK" = "0" ]; then echo "[FAIL] SimplySports"; echo "17" > "$P"; return 0; fi; unzip -o SimplySports.zip; mv SimplySports-main SimplySports; rm -f SimplySports.zip; echo "18" > "$P"; DONE=18; export PATH="/tmp/noreboot:$PATH"; }
install_autosub() { if [ "36" -le "$DONE" ]; then return 0; fi; echo "== [36] AutoSub NO reboot =="; wait_for_net; OK=0; for i in 1 2 3 4 5 6 7 8 9 10; do rm -f /tmp/AutoSub.tar.gz; wget -q --no-check-certificate --tries=3 --timeout=30 -O /tmp/AutoSub.tar.gz https://raw.githubusercontent.com/HBK2010/AutoSub/main/AutoSub.tar.gz; if [ -s /tmp/AutoSub.tar.gz ]; then OK=1; break; fi; sleep 15; wait_for_net; done; if [ "$OK" = "0" ]; then echo "[FAIL] AutoSub"; echo "35" > "$P"; return 0; fi; tar xzf /tmp/AutoSub.tar.gz -C /usr/lib/enigma2/python/Plugins/Extensions; rm -f /tmp/AutoSub.tar.gz; echo "[BLOCKED] init skipped"; echo "36" > "$P"; DONE=36; }
install_last() { if [ "37" -le "$DONE" ]; then return 0; fi; echo "== [37] SubExtractorLite LAST VERIFY =="; wait_for_net; OK=0; for i in 1 2 3 4 5 6 7 8 9 10; do rm -f /tmp/_s.sh; echo "[TRY $i/10] SubExtractorLite..."; wget --no-check-certificate --tries=3 --timeout=30 https://raw.githubusercontent.com/Arian7s/SubExtractorLite/main/installer.sh -O /tmp/_s.sh; if [ -s /tmp/_s.sh ]; then echo "Size: $(wc -c < /tmp/_s.sh)"; grep -q SubExtractor /tmp/_s.sh && echo "Content OK" && OK=1 && break; echo "[WARN] Wrong content"; else echo "[RETRY] $i/10"; fi; sleep 15; wait_for_net; done; if [ "$OK" = "0" ]; then echo "[FAIL] SubExtractorLite NOT INSTALLED"; echo "36" > "$P"; return 0; fi; sed -i -e '/^[[:space:]]*reboot/d' -e 's/;[[:space:]]*reboot/; echo [BLOCKED]/g' -e '/killall.*enigma2/d' -e '/init[[:space:]]*4/d' -e '/init[[:space:]]*3/d' /tmp/_s.sh; PATH="$ORIG_PATH" /bin/sh /tmp/_s.sh; sleep 3; ls /usr/lib/enigma2/python/Plugins/Extensions/ | grep -i SubExtractor >/dev/null 2>&1 && echo "[OK] SubExtractorLite Installed" || { echo "[WARN] Retry 2nd..."; PATH="$ORIG_PATH" /bin/sh /tmp/_s.sh; sleep 3; ls /usr/lib/enigma2/python/Plugins/Extensions/ | grep -i SubExtractor && echo "[OK] Installed 2nd try" || echo "[FAIL] Still not found"; }; echo "37" > "$P"; DONE=37; rm -f /tmp/_s.sh; export PATH="/tmp/noreboot:$PATH"; }

install_one "1" "update-all-python" "https://raw.githubusercontent.com/emil237/updates-enigma/main/update-all-python.sh"
opkg install wget
install_one "2" "MyStreamer" "https://raw.githubusercontent.com/popking159/MyStreamer/refs/heads/main/myinstaller.sh"
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
clear; echo "=========================================================="; echo "   All-Script By Eng Ahmed Abdel-Moati"; echo "   Copyright (c) 2026 Eng / Ahmed Abdel-Moati"; echo "=========================================================="; echo ""; echo "   اختار ملف القنوات اللي عايز تنزله :"; echo "   Choose the channel list you want to install :"; echo ""; echo "----------------------------------------------------------"; echo "   [ 1 ]  Emil Nabil  -  اميل نبيل"; echo "          الملف الكامل - القائمة الرئيسية"; echo ""; echo "   [ 2 ]  Mnasr  -  منصر"; echo "          الملف الكامل - القائمة البديلة"; echo ""; echo "   [ 3 ]  Khaled  -  خالد"; echo "          الملف الكامل - القائمة البديلة"; echo ""; echo "   [ 4 ]  Hazem Wahba  -  حازم وهبة"; echo "          الملف الكامل - القائمة البديلة"; echo "----------------------------------------------------------"; echo "   [ 0 ]  Skip  -  تخطي"; echo "          كمل من غير ما تنزل ملف قنوات"; echo "----------------------------------------------------------"; echo ""; echo "   ملحوظة : اختار رقم واحد بس من 0 لـ 4"
while true; do printf "   اكتب الرقم هنا واضغط Enter  [ 0-4 ] : "; read CH; case "$CH" in 1) CH_NAME="Emil Nabil - اميل نبيل"; CH_URL="https://raw.githubusercontent.com/emilnabil/channel-emil-nabil/main/installer.sh"; break ;; 2) CH_NAME="Mnasr - منصر"; CH_URL="https://raw.githubusercontent.com/emilnabil/channel-mnasr/main/installer.sh"; break ;; 3) CH_NAME="Khaled - خالد"; CH_URL="https://raw.githubusercontent.com/emilnabil/channel-khaled/main/installer.sh"; break ;; 4) CH_NAME="Hazem Wahba - حازم وهبة"; CH_URL="https://raw.githubusercontent.com/emilnabil/channel-hazem-wahba/main/installer.sh"; break ;; 0) CH_NAME="Skip"; break ;; *) echo ""; echo "   !!! رقم غلط - اكتب رقم من 0 لـ 4 بس !!!"; echo ""; continue ;; esac; done
if [ "$CH" = "0" ]; then echo ""; echo "   تم التخطي - هنكمل من غير ملف قنوات"; else echo ""; echo "   انت اخترت : $CH_NAME"; printf "   متأكد ؟ اكتب y للموافقة او n للالغاء [ y/n ] : "; read CONFIRM; if [ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "Y" ] || [ "$CONFIRM" = "1" ]; then echo ""; echo "   جاري تحميل ملف القنوات ... انتظر ..."; wget -q --no-check-certificate "$CH_URL" -O - | /bin/sh; echo ""; echo "   تم - Done - ملف القنوات نزل بنجاح"; else echo ""; echo "   تم الالغاء - هنكمل من غير ملف قنوات"; fi; fi
echo ""; echo "Copyright (c) 2026 Eng / Ahmed Abdel-Moati - ALL DONE - REAL restart now"; export PATH="$ORIG_PATH"; rm -rf /tmp/noreboot /tmp/_i.sh; rm -f "$P"; sleep 2; reboot; exit 0
