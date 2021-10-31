# VU-InGame-RCON
## Does stuff.
Use with VU Console.

Add Admins in Shared/Config.lua -
You can also handle temporary Admins with 
```
temporaryAdmins.add {name}
temporaryAdmins.remove {name}
temporaryAdmins.list
```
You call all RCON Commands as:
```
vu-ingame-rcon.{command} {value}
```

I recommend to change the folder name of the mod to something shorter that you would like as prefix.
e.G folder name: rcon
--> new command structure: 
```
rcon.{command} {value}
```


RCON Documentation:
https://github.com/dcodeIO/BattleCon/blob/master/eadocs/BF3/BF3%20PC%20Server%20Remote%20Administration%20Protocol.pdf



## Advanced RCON
Doesn´t include commands introduced by AdvancedRCON by Bree
https://github.com/FlashHit/AdvancedRCON
Feel free to add the commands manually if you want to use them.


