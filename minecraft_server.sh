#!/bin/bash

#Script for managing Minecraft servers.
#Copyright (C) 2018  Dr.Fr4nk3n5731n
#
#This program is free software; you can redistribute it and/or
#modify it under the terms of the GNU General Public License
#as published by the Free Software Foundation; either version 2
#of the License, or (at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program; if not, see <https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html>


#change to configure
INPUT_FILE="server.input"
OUTPUT_FILE="server.output"
PID_FILE="server.pid"
START_ARGUMENTS="-Dcom.mojang.eula.agree=true -Djline.terminal=jline.UnsupportedTerminal -Xms512m -Xmx8g -XX:PermSize=2g -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:+CMSIncrementalPacing -XX:ParallelGCThreads=20 -XX:+AggressiveOpts"
MINECRAFT_ARGUMENTS="nogui"
SERVER_FILE="minecraft_server.jar"
RESTART_MESSAGE="Server will now restart"


SERVER_PID="$(cat $PID_FILE)"

server_setup () {
  declare -a FILES=("$OUTPUT_FILE" "$PID_FILE")
  for FILE in $FILES; do
    if [ ! -f "$FILE" ]; then
      echo "File \"$FILE\" not found. File will now be created."
      touch "$FILE"
    fi
  done
  if [ ! -f "$INPUT_FILE" ]; then
    echo "File \"$INPUT_FILE\" not found. File will now be created."
    mkfifo "$INPUT_FILE"
  fi  
}

server_running () {
  if kill -s 0 $SERVER_PID 2>/dev/null; then
    return 0
  else
    return 1
  fi
}

status () {
  if server_running; then
    echo "Server is Running ($SERVER_PID)"
  else
    echo "Server is not running"
  fi
}

say () {
  if server_running; then
    echo "say [$(logname)]: $@" > "$INPUT_FILE"
  else
    echo "Can't execute say. Server isn't running!"
  fi
}

execute () {
  if server_running; then
    if [[ "$1" = "say" ]]; then
      say "${@:2}"
    else
      echo "$@" > "$INPUT_FILE"      
    fi  
  else
    echo "Can't execute commands. Server isn't running!"
  fi  
  
}

stop () {
  kill $SERVER_PID 2>/dev/null
  sleep 5
  if ! server_running; then
    echo "Server stopped."
    > "$PID_FILE"
    tar -cJf "$(date '+%Y.%m.%d-%H:%M:%S')_$OUTPUT_FILE.tar.xz" "$OUTPUT_FILE" 
  else
    echo "Server could not be stopped!"
    echo "please check if PID $SERVER_PID exsits"
  fi
}

start () {
  server_setup
  if server_running; then
    echo "The Server is already running"
  else
    tail -f "$INPUT_FILE" | java "$START_ARGUMENTS" -jar "$SERVER_FILE" "$MINECRAFT_ARGUMENTS" > "$OUTPUT_FILE" 2>&1  &
    NEW_PID=$!
    echo $NEW_PID > "$PID_FILE"
    echo "Server started with PID $NEW_PID"
  fi
}

reload () {
  execute "reload"
}

help () {
  echo "usage: ./$0 command [arguments]"
  echo "commands:"

  echo "pid"
  echo "get process id from server."

  echo "start"
  echo "start minecraft server."

  echo "stop"
  echo "stop minecraft server."

  echo "restart"
  echo "restart minecraft server."

  echo "say <message>"
  echo "execute say command no the server."

  echo "status"
  echo "check if minecraft server is running."

  echo "reload"
  echo "reload all plugins on the server."

  echo "execute <command>"
  echo "execute given command on minecraft server. For a list of commands for Vanilla Minecraft server go to <https://minecraft.gamepedia.com/Commands>"
}

case $1 in
  pid)
  echo "$SERVER_PID"
  ;;
  setup)
  server_setup
  ;;
  start)
  start
  ;;
  stop)
  stop
  ;;
  restart)
  if [[ -n "$RESTART_MESSAGE" ]]; then
    execute "say $RESTART_MESSAGE"
  fi;
  echo "[$(date '+%H:%M:%S')] [Server thread/Restart]: Restart initialized by System User: \"$(logname)\"" >> "$OUTPUT_FILE"
  stop && sleep 5 && start
  ;;
  say)
  say ${*:2}
  ;;
  status)
  status
  ;;
  reload)
  reload
  ;;
  execute)
  execute ${*:2}
  ;;
  help)
  help
  ;;
esac
