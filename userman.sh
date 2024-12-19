#!/bin/bash

list_users() {
  users=$(cut -d: -f1 /etc/passwd)
  menu_items=()
  for user in $users; do
    menu_items+=("$user" "$user")
  done

  selected_user=$(dialog --backtitle "Jamm Security" --stdout --menu "Select a user" 20 50 15 "${menu_items[@]}")
  echo "$selected_user"
}

list_human_users() {
  human_users=$(awk -F: '($3 >= 1000 && $3 < 65534) {print $1}' /etc/passwd)
  menu_items=()
  for user in $human_users; do
    menu_items+=("$user" "$user")
  done

  selected_user=$(dialog --backtitle "Jamm Security" --stdout --menu "Select a user" 20 50 15 "${menu_items[@]}")
  echo "$selected_user"
}

view_user_stats() {
  local user=$1
  if id "$user" &>/dev/null; then
    if groups "$user" | grep -qwE 'sudo|wheel'; then
      sudo_status="Yes"
    else
      sudo_status="No"
    fi

    groups=$(id -nG "$user")
    pids=$(pgrep -u "$user" | tr '\n' ' ')

    dialog --msgbox "User: $user\nSudo: $sudo_status\nGroups: $groups\nPIDs: ${pids:-None}" 15 50
  else
    dialog --msgbox "Error: User '$user' does not exist." 10 50
  fi
}

toggle_sudo() {
  local user=$1
  if id "$user" &>/dev/null; then
    if groups "$user" | grep -qw sudo; then
      sudo deluser "$user" sudo
      dialog --msgbox "Removed sudo privileges from $user." 10 40
    else
      sudo adduser "$user" sudo
      dialog --msgbox "Granted sudo privileges to $user." 10 40
    fi
  else
    dialog --msgbox "User $user does not exist." 10 40
  fi
}

remove_user() {
  local user=$1
  if id "$user" &>/dev/null; then
    dialog --yesno "Are you sure you want to remove $user?" 10 40
    if [[ $? -eq 0 ]]; then
      dialog --yesno "Do you want to delete the home directory for $user?" 10 40
      local delete_home=$?
      if [[ $delete_home -eq 0 ]]; then
        sudo userdel -r "$user"
      else
        sudo userdel "$user"
      fi
      dialog --msgbox "User $user has been removed." 10 40
    fi
  else
    dialog --msgbox "User $user does not exist." 10 40
  fi
}

add_user() {
  while true; do
    new_user=$(dialog --backtitle "Jamm Security" --stdout --inputbox "Enter the new username:" 10 40)
    if [[ $? -ne 0 ]]; then
      break
    fi
    if [[ -n $new_user ]]; then
      if sudo useradd -m "$new_user" && sudo passwd "$new_user"; then
        dialog --msgbox "User $new_user has been added." 10 40
      else
        dialog --msgbox "Failed to add user $new_user. Please check your input." 10 40
      fi
    else
      dialog --msgbox "No username provided. Returning to the Add User menu." 10 40
    fi
  done
}

while true; do
  action=$(dialog --backtitle "Jamm Security" --stdout --menu "User Management" 20 50 10 \
    1 "List All Users" \
    2 "List Human Users" \
    3 "Add User" \
    4 "Exit")

  case $action in
    1)
      while true; do
        user=$(list_users)
        if [[ -z $user ]]; then
          break
        fi
        choice=$(dialog --backtitle "Jamm Security" --stdout --menu "Manage $user" 20 50 10 \
          1 "View Stats" \
          2 "Toggle Sudo Privileges" \
          3 "Remove User")

        case $choice in
          1) view_user_stats "$user" ;;
          2) toggle_sudo "$user" ;;
          3) remove_user "$user" ;;
        esac
      done
      ;;
    2)
      while true; do
        user=$(list_human_users)
        if [[ -z $user ]]; then
          break
        fi
        choice=$(dialog --backtitle "Jamm Security" --stdout --menu "Manage $user" 20 50 10 \
          1 "View Stats" \
          2 "Toggle Sudo Privileges" \
          3 "Remove User")

        case $choice in
          1) view_user_stats "$user" ;;
          2) toggle_sudo "$user" ;;
          3) remove_user "$user" ;;
        esac
      done
      ;;
    3) add_user ;;
    4) break ;;
  esac
done
