# pterodactyl-eggs

## How to import an egg

If you are reading this it looks like you are looking to add an egg to your server.

1. Download any of the json files located in the folders below.
   1. It's easiest to right click the `raw` button and save as.
2. In your panel go to the `Nests` section in the admin part of the panel
3. Click the green `Import Egg` button
4. Browse to the json file you saved earlier
5. Select what nest you want to put the egg in.
   1. If you want a new nest you need to create it before importing the egg.

# You must restart your daemon after importing an egg if you are using 0.7. This is not required on 1.X.

## [Game Eggs](/game_eggs)
### [Minecraft](game_eggs/minecraft)
* [Java](game_eggs/minecraft/java) Servers for Java Minecraft
  * [Forge](game_eggs/minecraft/java/forge)  
  * [Paper](game_eggs/minecraft/java/paper)
* [Proxies](game_eggs/minecraft/proxy) Minecraft Server Proxies
  * [Java](game_eggs/minecraft/proxy/java)
    * [Velocity](game_eggs/minecraft/proxy/java/velocity)
    * [Waterfall](game_eggs/minecraft/proxy/java/waterfall)
  * [Cross Platform](game_eggs/minecraft/proxy/cross_platform)
    * [GeyserMC](game_eggs/minecraft/proxy/cross_platform/geyser)
## [Database](/database)
### In-Memory Databases
[Redis](/database/redis)
* [Redis 5](/database/redis/redis-5)
* [Redis 6](/database/redis/redis-6)
### SQL Databases
* [MariaDB](/database/sql/mariadb)
* [PostgreSQL](/database/sql/postgres)
## [Software](/software/)
### Code Server
* [Code-Server](/software/code-server)
## [Bots](/bots)
### [Discord](/bots/discord)
* [discord.py](bots/discord/discord.py) Python generic