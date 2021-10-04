#!/bin/bash

interval=0

cpu() {
  cpu_val=$(grep -o "^[^ ]*" /proc/loadavg)

  printf "^c#3b414d^ ^b#50fa7b^ CPU"
  printf "^c#abb2bf^ ^b#282a36^ $cpu_val"
}

update_icon() {
  printf "^c#ffb86c^ "
}

pkg_updates() {
  updates=$(sudo xbps-install -un | wc -l) # void
  # updates=$(checkupdates | wc -l)   # arch , needs pacman contrib
  # updates=$(aptitude search '~U' | wc -l)  # apt (ubuntu,debian etc)

  if [ -z "$updates" ]; then
    printf "^c#50fa7b^ Fully Updated"
  else
    printf "^c#ffb86c^ $updates"" updates"
  fi
}

# battery
batt() {
  printf "^c#6272a4^  "
  printf "^c#6272a4^ $(acpi | sed "s/,//g" | awk '{if ($3 == "Discharging"){print $4; exit} else {print $4""}}' | tr -d "\n")"
}

brightness() {

  backlight() {
    backlight="$(xbacklight -get)"
    echo -e "$backlight"
  }

  printf "^c#ff5555^   "
  printf "^c#ff5555^%.0f\n" $(backlight)
}

mem() {
  printf "^c#6272a4^  "
  printf "^c#6272a4^ $(free -h | awk '/^Mem/ { print $3 }' | sed s/i//g)"
}

wlan() {
  case "$(cat /sys/class/net/w*/operstate 2>/dev/null)" in
  up) printf "^c#3b414d^ ^b#bd93f9^ 󰤨 ^d^%s" " ^c#828dd1^Connected" ;;
  down) printf "^c#3b414d^ ^b#282a36^ 󰤭 ^d^%s" " ^c#828dd1^Disconnected" ;;
  esac
}

clock() {
  printf "^c#2E3440^ ^b#ff79c6^ 󱑆 "
  printf "^c#50fa7b^^b#282a36^ $(date '+%a, %I:%M %p') "
}

while true; do

  [ $interval == 0 ] || [ $(($interval % 3600)) == 0 ] && updates=$(pkg_updates)
  interval=$((interval + 1))

  sleep 1 && xsetroot -name "$(update_icon) $updates $(batt) $(brightness) $(cpu) $(mem) $(wlan) $(clock)"
done
