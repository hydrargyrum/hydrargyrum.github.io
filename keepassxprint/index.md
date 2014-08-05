---
layout: mine
title: KeePassXPrint
---

# keepassxprint

Print info and passwords from a KeePassX password database

# KeePassX #

[KeePassX](https://www.keepassx.org/) is a graphical application to store usernames and password in an encrypted database to avoid forgetting them, while maintaining differents passwords for each account.
The database is protected by a master password to unlock all or a key file.

# KeePassXPrint #

KeePassXPrint is a command-line tool to display data from a database made with KeePassX.
KeePassXPrint always prompts for the database's password at start.

It can display all accounts from a database:

```
% python keepassxprint -f example.kdb
Password: 
title: Work
title: Box
```

If a pattern is given, detailed information is printed for each account whose title matches the pattern:

```
% python keepassxprint -f example.kdb --show-password 'Work*'
Password: 
title: Work
username: taanderson@metacortex.corp
password: hunter2
```

# Download #

[Project repository](https://github.com/hydrargyrum/attic/tree/master/keepassxprint)

keepassxprint uses Python 2 and is licensed under the [WTFPLv2](../wtfpl).
