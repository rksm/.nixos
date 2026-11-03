# Brings the WezTerm tab with a Herdr session's client to the front. The
# Herdr dashboard runs it as its focus-hook (config.yaml), after f focused an
# agent.
#
# The dashboard names the agent's session in HERDR_DASHBOARD_SESSION, and for
# a saved machine its SSH target in HERDR_DASHBOARD_SSH_TARGET.
#
# - A client of this machine's session is the herdr process at the top of
#   its terminal, with the session in --session or else in HERDR_SESSION.
# - A client of a saved machine's session keeps an SSH bridge to it:
#   `ssh … -T <target> … herdr --session <session> remote-client-bridge`.
#   The client of `herdr --remote` has one, and so has this machine's
#   client, which shows the saved machines too.
#
# wezterm comes from PATH, so that it matches the running WezTerm. GNOME on
# Wayland lets no other program raise a window. The computer-use-linux
# extension can, over D-Bus.

session=${HERDR_DASHBOARD_SESSION:?no Herdr session named}
target=${HERDR_DASHBOARD_SSH_TARGET:-}
bus=dev.avifenesh.ComputerUseLinux.WindowControl
path=/dev/avifenesh/ComputerUseLinux/WindowControl

# Whether the terminal $1, such as /dev/pts/0, runs a client of the session.
shows_session() {
  local pid ppid comm args
  while read -r pid ppid comm args; do
    if [ -n "$target" ]; then
      if [ "$comm" = ssh ] &&
        [[ " $args " == *" -T $target "*" --session $session remote-client-bridge "* ]]; then
        return 0
      fi
    elif [ "$comm" = herdr ] && [ "$(ps -o comm= -p "$ppid")" != herdr ] &&
      [[ " $args " != *" --remote "* ]]; then
      if [[ " $args " == *" --session $session "* ]]; then
        return 0
      fi
      if [[ " $args " != *" --session "* ]] &&
        grep -qzxF "HERDR_SESSION=$session" "/proc/$pid/environ"; then
        return 0
      fi
    fi
  done < <(ps -t "${1#/dev/}" -o pid=,ppid=,comm=,args= 2>/dev/null)
  return 1
}

pane=
while read -r id tty; do
  if shows_session "$tty"; then
    pane=$id
    break
  fi
done < <(wezterm cli list --format json | jq -r '.[] | "\(.pane_id) \(.tty_name)"')
# No tab shows the session, such as one that Robert follows from another
# machine: there is nothing to bring forward.
if [ -z "$pane" ]; then
  exit 0
fi

wezterm cli activate-pane --pane-id "$pane"

# lessismore: raises the first WezTerm window, as `wezterm cli list` names
# no GNOME window. Revisit when Robert keeps more than one WezTerm window.
window=$(busctl --user --json=short call "$bus" "$path" "$bus" ListWindows |
  jq -r '.data[0] | fromjson
    | map(select(.wm_class == "org.wezfurlong.wezterm")) | .[0].window_id // empty')
if [ -z "$window" ]; then
  echo "GNOME shows no WezTerm window" >&2
  exit 1
fi
answer=$(busctl --user --json=short call "$bus" "$path" "$bus" ActivateWindow t "$window")
if ! jq -e '.data[0]' <<<"$answer" >/dev/null; then
  jq -r '.data[1]' <<<"$answer" >&2
  exit 1
fi
