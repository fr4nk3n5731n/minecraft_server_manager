# minecraft_server_manager
Simple script for managing Minecraft server ie. starting, stopping, restarting without the need for screen

This script is the result of me being bored.

To check/see the output of the minecraft server either use tail or cat or whatever you want to read the output file.

# Usage
  ./minecraft_server.sh command [arguments]"
  
## Commands
### pid
usage: ./minecraft_server.sh pid  
description: get process id from server

### start
usage: ./minecraft_server.sh start  
description: starts server.

### stop
usage: ./minecraft_server.sh stop  
description: stops servers.

### restart
usage: ./minecraft_server.sh restart  
descriptions: restarts server with restart message if configured.

### say
usage: ./minecraft_server.sh say <message>  
description: execute say command on the server with system username infront the message.

### status
usage: ./minecraft_server.sh status  
description: checks if server is running.  

### reload
usage: ./minecraft_server.sh reload  
description: reload all plugins on the server.

### execute <command>
usage: ./minecraft_server.sh command [arguments]  
description: execute given command on minecraft server. For a list of commands for Vanilla Minecraft server go to <https://minecraft.gamepedia.com/Commands>
