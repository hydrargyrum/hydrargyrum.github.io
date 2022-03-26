---
title: Revoking LUKS keys?
last_modified_at: 2022-03-26T11:36:02+01:00
tags: encryption luks filesystem
---

# Revoking LUKS keys?

[LUKS](https://en.wikipedia.org/wiki/Linux_Unified_Key_Setup) drive encryption allows multiple keys, which can be used so several users can decrypt a drive.
Those "user keys" can be manipulated with [`cryptsetup luksAddKey` and `cryptsetup luksRemoveKey`].
It may seem LUKS thus has a convenient feature to revoke a key and prohibit it from ever decrypting the drive again!

[`cryptsetup luksAddKey` and `cryptsetup luksRemoveKey`]: https://manpages.debian.org/stable/cryptsetup-bin/cryptsetup.8.en.html

Unfortunately, revoking a key is not as definitive as it may seem.
Indeed, the payload is not encrypted with any of the user keys but with a "master key", generated once, when formatting the LUKS drive.
The master key is then encrypted with each of the user keys, and stored encrypted in the [LUKS header] of the drive.

[LUKS header]: https://security.stackexchange.com/questions/109223/what-does-luks-header-contain

![LUKS header](luks-header.png)

# Testing

### Initial setup

First, create a LUKS volume, ~50MiB, with a user key in `foo.key`.

```sh
# dd bs=1024 count=50000 if=/dev/zero of=lukstest.disk
# printf foo > foo.key
# cryptsetup luksFormat -v -q lukstest.disk foo.key
Key slot 0 created.
Command successful.
```

`foo` user allows another user, `bar`, to decrypt the drive:

```sh
# printf bar > bar.key
# cryptsetup luksAddKey -v --key-file foo.key lukstest.disk bar.key
Key slot 1 created.
Command successful.
```

We can check that we can succesfully decrypt the drive with `bar.key`.

```sh
# cryptsetup luksOpen -v --test-passphrase lukstest.disk --key-file bar.key && echo OK
No usable token is available.
Key slot 1 unlocked.
Command successful.
OK
```

### Dump

The user with `bar` key wants to make sure their key cannot be revoked anymore, and backups the LUKS header:
```
# cryptsetup luksHeaderBackup -v lukstest.disk --header-backup-file lukstest.hdr
Command successful.
```

In doing so, `bar` keeps a copy of the master key, encrypted with at least their own key (`bar`).

### Tentatively revoking

`foo` thinks `bar` is evil, and revokes their key:

```sh
# cryptsetup luksKillSlot -v --key-file foo.key lukstest.disk 1
Keyslot 1 is selected for deletion.
Key slot 0 unlocked.
Key slot 1 removed.
Command successful.
```

### Failure

But it's too late! `bar` can restore the header and decrypt data again.

```sh
# cryptsetup luksHeaderRestore -v lukstest.disk --header-backup-file lukstest.hdr -q
Command successful.
# cryptsetup luksOpen -v --test-passphrase lukstest.disk --key-file bar.key && echo OK
No usable token is available.
Key slot 1 unlocked.
Command successful.
OK
```

Revoking keys LUKS only works if nobody had access to the LUKS header before that.
If the LUKS header is backed-up by someone, they can still attack the prior user keys afterwards and revoking those keys will not prevent them from being used to decrypt the drive.

This is stated in `cryptsetup luksHeaderBackup` manual:

> WARNING: This backup file and a passphrase valid at the time of backup allows decryption of the LUKS data area, even if the passphrase was later changed or removed from the LUKS device. Also note that with a header backup you lose the ability to  securely  wipe  the LUKS device by just overwriting the header and key-slots. You either need to securely erase all header backups in addition or overwrite the encrypted data area as well.  The second option is less secure, as some sectors can survive, e.g. due to defect management.


# Mitigation

Since `bar` has a copy of the master key, the only way to prevent them to access the data is to change the master key, which implies reencrypting the whole data, that may weigh gigabytes or even terabytes, thus lasting hours or even days.

This is done with `cryptsetup reencrypt` and requires extra care because it will process a lot of data, and during the operation, the drive is half-encrypted with one master key, half-encrypted with another key.
This could be risky especially if the system crashes or is rebooted during that time.

Remember this is only necessary if `bar` could have access to the LUKS header, for example with root access (maybe using security vulnerabilities) or with physical drive access.
