#!/bin/bash

interval=0

pause_cache_timeout()
{
	if [ X"$cache_timeout" = X"" ] ; then
		cache_timeout=0
	else
		[ $cache_timeout -ge 5 ] && music_= || cache_timeout=$(($cache_timeout + 1))
	fi
}

music()
{
  title=$(dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:org.mpris.MediaPlayer2.Player string:Metadata 2>/dev/null | awk '/artist/{getline;getline;print;}' | cut -d '"' -f 2)

  if [ ! -z "$title" ] ; then
    name=$(dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:org.mpris.MediaPlayer2.Player string:Metadata 2>/dev/null | sed -n '/title/{n;p}' | cut -d '"' -f 2)

    status=$(dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'PlaybackStatus'|egrep -A 1 "string"|cut -b 26-|cut -d '"' -f 1|egrep -v ^$)

    if [ "$status" = "Playing" ] ; then
      symbol_="π§"
    elif [ "$status" = "Paused" ] ; then
      symbol_="ο"
    fi

    # music_="$title οΌ $name"

    # printf "^c#b084f5^ $symbol_ ^c#81A1C1^γ$title ^c#abb2bf^οΌ ^c#81A1C1^$nameγ"
    printf "^c#b084f5^ $symbol_ ^c#545862^γ^c#4a6a8a^$title ^c#abb2bf^οΌ ^c#4a6a8a^$name^c#545862^γ^b#161a22^"

  else
    m_symbol_=$(mpc 2>/dev/null | head -n2 | tail -n1| cut -f 1 | sed "/^volume:/d;s/\\&/&amp;/g;s/\\[paused\\].*/ο/g;s/\\[playing\\].*/π§/g;/^ERROR/Q" | paste -sd ' ' -;)
    # m_symbol_=$(mpc | head -n2 | tail -n1| cut -f 1 | sed "/^volume:/d;s/\\&/&amp;/g;s/\\[paused\\].*/βΈ/g;s/\\[playing\\].*/π§/g;/^ERROR/Q" | paste -sd ' ' -;)

    if [ ! -z "$m_symbol_" ] ; then
      music_=$(mpc 2>/dev/null | sed "/^volume:/d;s/\\&/&amp;/g;/\\[paused\\].*/d;/\\[playing\\].*/d;/^ERROR/Q" | paste -sd ' ' -;)

      if [ ${#music_} -gt 39 ] ; then
        music_="γ$(echo $music_|cut -c1-39)...γ"
      else
        music_="γ$music_γ"
      fi

      # [ X"$m_symbol_" = X"ο" ] && pause_cache_timeout || cache_timeout=

      # printf "^c#b084f5^^b#11141e^ $music_  $m_symbol_ ^b#1e222a^"
      # printf "^c#81A1C1^$music_ ^c#b084f5^$m_symbol_  ^b#11141e^"
      printf "^c#b084f5^$m_symbol_ ^c#4a6a8a^$music_^b#161a22^"
    else
      music_=
    fi

  fi
}

cpu() {
  cpu_val=$(grep -o "^[^ ]*" /proc/loadavg)

  # # printf "^c#3b414d^ ^b#7ec7a2^ CPU"
  # printf "^c#3b414d^ ^b#668ee3^ CPU"
  # printf "^c#abb2bf^ ^b#353b45^ $cpu_val"
  printf "^c#bf616a^^b#10121b^ ο ^c#7797b7^$cpu_val"
}

disk_usage() {
	disk_root=$(df -h|awk '{if ($6 == "/") {print}}'|awk '{print "/" $5}'|sed 's/\%//')
	disk_home=$(df -h|awk '{if ($6 == "/home") {print}}'|awk '{print "~" $5}'|sed 's/\%//')

  printf "^c#ebcb8b^^b#121521^ πΎ ^c#7797b7^$disk_root%% ^b#11131b^- $disk_home%%"
}

update_icon() {
  printf "^c#7ec7a2^ ^b#132121^οΉ"
  # printf "^c#81A1C1^ οΉ"
}

pkg_updates() {
  # updates=$(doas xbps-install -un | wc -l) # void
  updates=$(checkupdates | wc -l)   # arch , needs pacman contrib
  # updates=$(aptitude search '~U' | wc -l)  # apt (ubuntu,debian etc)

  if [ -z "$updates" ]; then
    printf "^c#7797b7^ fully updated"
  else
    printf "^c#7797b7^$updates""^b#121921^u"
  fi
  # if [ -z "$updates" ]; then
  #   printf "^c#7ec7a2^ Fully Updated"
  # else
  #   printf "^c#7ec7a2^ $updates"" updates"
  # fi
}

# battery
batt() {
  printf "^c#81A1C1^ ο¦ "
  printf "^c#81A1C1^ $(acpi | sed "s/,//g" | awk '{if ($3 == "Discharging"){print $4; exit} else {print $4""}}' | tr -d "\n")"
}

brightness() {

  backlight() {
    backlight="$(xbacklight -get)"
    echo -e "$backlight"
  }

  printf "^c#BF616A^ ο  "
  printf "^c#BF616A^%.0f\n" $(backlight)
}

mem() {
  # printf "^c#7797b7^^b#0f131b^ ξ¦"
  # printf "^c#ebcb8b^^b#2E3440^ ξ¦"
  printf "^c#69ccff^^b#10121a^ ξ¦"
  printf "^c#7797b7^ $(free -h | awk '/^Mem/ { print $3 }' | sed s/i//g) ^c#545862^^b#0d1113^| ^c#7797b7^$(free -h | awk '/^Mem/ { print $6 }' | sed s/i//g) ^c#545869^^b#0c0e13^- $(free -h | awk '/^Swap/ { print $3 }' | sed s/i//g)"
}

wlan() {
  # net_icon=`printf "%s%s%s\n" "$wifiicon" "$(sed "s/down/οͺ/;s/up/οΏ/" /sys/class/net/e*/operstate 2>/dev/null)" "$(sed "s/.*/π/" /sys/class/net/tun*/operstate 2>/dev/null)"`
  net_icon=`printf "%s%s%s\n" "$wifiicon" "$(sed "s/down/οͺ/;s/up/π/" /sys/class/net/e*/operstate 2>/dev/null)" "$(sed "s/.*/π/" /sys/class/net/tun*/operstate 2>/dev/null)"`

  if [ X"$net_icon" = X"οͺ" ]; then
    printf "^c#bd93f9^^b#0f1113^ $net_icon"
  else
    # printf "^c#9266d7^^b#0f1113^ $net_icon"
    printf "^c#9266d7^^b#071309^ $net_icon"
    # printf "^c#7797b7^^b#11141e^ $net_icon"
  fi

  case "$(cat /sys/class/net/w*/operstate 2>/dev/null)" in
    up)
      # printf "^c#3b414d^ ^b#7aa2f7^ σ°€¨ ^d^%s" " ^c#7aa2f7^Connected"
      printf "^c#7797b7^ ^b#11141e^ σ°€¨ ^d^%s"
      ;;
    down)
      # printf "^c#3b414d^ ^b#7aa2f7^ σ°€­ ^d^%s" " ^c#7aa2f7^Disconnected"
      printf "^c#bf616a^ ^b#11141e^ σ°€­ ^d^%s"
      ;;
  esac
}

clock() {

  # marine blue scheme
  # printf "^c#0f131b^^b#6282a2^ σ± "
  # printf "^c#1e222a^^b#7c9cbc^ $(date '+%a, %I:%M %p') "
  
  # purple scheme
  printf "^c#121419^^b#9a62dd^ σ± "
  # printf "^c#121419^^b#9266d7^$(date '+β·%m.%d.%yβ· %H:%M')"
  printf "^c#121419^^b#9266d7^$(date '+%H:%M β· %m.%d.%y')"

  # blue scheme
  # printf "^c#2E3440^^b#828dd1^ σ± "
  # printf "^c#2E3440^^b#6c77bb^ $(date '+%a, %I:%M %p') "
}

while true; do

  [ $interval == 0 ] || [ $(($interval % 3600)) == 0 ] && updates=$(pkg_updates) && disk_u=$(disk_usage) && interval=0
  interval=$((interval + 1))

  # sleep 1 && xsetroot -name "$(update_icon) $updates $(batt) $(brightness) $(cpu) $(mem) $(wlan) $(clock)"
  sleep 1 && xsetroot -name "                     $(music) $(update_icon) $updates  $disk_u  $(cpu)  $(mem) $(clock) $(wlan) "

done
