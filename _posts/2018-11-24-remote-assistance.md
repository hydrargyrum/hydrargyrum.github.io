---
layout: mine
title: SSH remote assistance
tags: ssh assistance
---

# Remote SSH assistance

Sometimes, one needs to provide remote assistance to a family member for their computer.

Their constraints are:
* they are barely able to type a command in a shell
* they might be behind a firewall preventing incoming connections

It's possible to setup their computer so that:
* you can access their computer with a reverse SSH tunnel
* they can start an SSH tunnel to your workstation when they want
* you can't access their computer at any other time
* they cannot do anything on your workstation

## Notes

In the following snippets, it's assumed their username is `them`, your username is `me` and your workstation host is `me.example.com`.

# On your workstation

## Add a user

Add a user dedicated to `<them>`:

	adduser --shell /bin/false them

Since their shell is `/bin/false`, they won't be able to run anything on your workstation.

The `/etc/passwd` file should contain a line like:

	them:x:1001:1001:,,,:/home/them:/bin/false

## `/etc/ssh/sshd_config`

Add this:

	Match User them
		AllowTcpForwarding remote
		X11Forwarding no
		PermitTTY no
		AllowAgentForwarding no
		AllowStreamLocalForwarding no

This will only allow them to create reverse SSH tunnels, no other forwarding and no running commands.

For good measure, you could also add:

	AllowUsers me them

Which would restrict `ssh` access to you and them.

## `~me/.ssh/config`

	Host assistance
		User me
		HostName localhost
		Port 10022

# On their machine

It is needed you install an SSH server on their machine. If they're behind a firewall, it might not be necessary to secure their side more.

## Add yourself to the users

	adduser me

## `/etc/ssh/sshd_config`

Allow only yourself:

	AllowUsers me

## `~them/.ssh/config`

	Host assistance
		User them
		HostName me.example.com
		RemoteForward 10022 localhost:22
		ExitOnForwardFailure yes

To avoid basic bots, I run my SSH server on a different port than 22, so you will need to append `Port 44` after these lines (if the port is 44).

## `~them/.zshrc` or `~them/.bashrc`

An alias can be added in their shell so they can type the least to start the assistance:

	alias assistance='ssh -N assistance'

A `.sh` script or a shortcut can also be made on their desktop directory.

## `~them/Desktop/assistance.desktop`

A shortcut:

	[Desktop Entry]
	Version=1.0
	Type=Application
	Exec=ssh -N assistance
	Name=Assistance
	Terminal=true
	Icon=help-browser

And don't forget to make it executable:

	chmod +x ~them/Desktop/assistance.desktop

# Use

When they need help, you can tell them to open a terminal and type `assistance` in it (or launch the desktop shortcut if you made one). Then, you can simply run `ssh assistance`.

# To go further

It's better if instead of authenticating them with a password, they authenticate using a public key only on the workstation. Generate a keypair (with `ssh-keygen`), copy it to the workstation (with `ssh-copy-id`) and set `AuthenticationMethods publickey` for them. That avoids having them typing a (new) password. Conversely, you can authenticate on their machine with a public key.

If they're not behind a firewall, it might be useful to secure their machine as your workstation: e.g. changing SSH server port, installing `fail2ban`, etc.

If the default SSH server port is changed, it's better if it's < 1024.

It can be useful to tunnel VNC traffic for display assistance (for example with something like `RemoteForward 10900 localhost:5900`). `Compression` could be enabled then. Or use RDP/NX.
