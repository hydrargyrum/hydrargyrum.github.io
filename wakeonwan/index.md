---
layout: mine
---

# wakeonwan

Wake remote machines with Wake-on-WAN

# wakeonwan #

Wake-on-WAN is similar to the Wake-on-LAN protocol, except it works across the internet. When receiving a WoW packet, the machine responding at the target IP (typically a router) should dispatch a regular WoL packet on its LAN. This command is just for sending the Wake-on-WAN packet.

# Sample usage #

```
wakeonwan myhost.example.org 12-34-56-78-9A-BC
```

# Download #

wakeonwan requires Ruby and is licensed under the [WTFPLv2](../wtfpl).

[Project repository](https://github.com/hydrargyrum/attic/tree/master/wakeonwan)
