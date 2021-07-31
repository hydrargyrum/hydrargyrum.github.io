---
layout: mine
title: El-Cheapo security updates in Docker images
last_modified_at: 2021-07-31T16:14:39+02:00
tags: docker
accept_comments: true
---

# El-Cheapo security updates in Docker images

Let's check the [`python:3`](https://hub.docker.com/_/python) image (which is current stable Python version) for security problems using trivy.

# Introducing trivy

We'll use [trivy](https://aquasecurity.github.io/trivy/) which scans images for outdated package versions and [CVEs](https://en.wikipedia.org/wiki/Common_Vulnerabilities_and_Exposures) affecting those packages.

First, let's show what trivy's structure look like, with [`flatten-json`](https://gitlab.com/hydrargyrum/attic/-/tree/master/flatten-json):

{% raw %}
```
% docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v trivy-cache:/root/.cache/ aquasec/trivy -q i -f json python:3 | flatten-json | pjy
{
  "0/Target": "python:3 (debian 10.10)",
  "0/Class": "os-pkgs",
  "0/Type": "debian",
  "0/Vulnerabilities/0/VulnerabilityID": "CVE-2011-3374",
  "0/Vulnerabilities/0/PkgName": "apt",
  "0/Vulnerabilities/0/InstalledVersion": "1.8.2.3",
  "0/Vulnerabilities/0/Layer/DiffID": "sha256:afa3e488a0ee76983343f8aa759e4b7b898db65b715eb90abc81c181388374e3",
  "0/Vulnerabilities/0/SeveritySource": "debian",
  "0/Vulnerabilities/0/PrimaryURL": "https://avd.aquasec.com/nvd/cve-2011-3374",
  "0/Vulnerabilities/0/Description": "It was found that apt-key in apt, all versions, do not correctly validate gpg keys with the master keyring, leading to a potential man-in-the-middle attack.",
  "0/Vulnerabilities/0/Severity": "LOW",
  "0/Vulnerabilities/0/CweIDs/0": "CWE-347",
  "0/Vulnerabilities/0/CVSS/nvd/V2Vector": "AV:N/AC:M/Au:N/C:N/I:P/A:N",
  "0/Vulnerabilities/0/CVSS/nvd/V3Vector": "CVSS:3.1/AV:N/AC:H/PR:N/UI:N/S:U/C:N/I:L/A:N",
  "0/Vulnerabilities/0/CVSS/nvd/V2Score": 4.3,
  "0/Vulnerabilities/0/CVSS/nvd/V3Score": 3.7,
  "0/Vulnerabilities/0/References/0": "https://access.redhat.com/security/cve/cve-2011-3374",
  "0/Vulnerabilities/0/References/1": "https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=642480",
  "0/Vulnerabilities/0/References/2": "https://people.canonical.com/~ubuntu-security/cve/2011/CVE-2011-3374.html",
  "0/Vulnerabilities/0/References/3": "https://seclists.org/fulldisclosure/2011/Sep/221",
  "0/Vulnerabilities/0/References/4": "https://security-tracker.debian.org/tracker/CVE-2011-3374",
  "0/Vulnerabilities/0/References/5": "https://snyk.io/vuln/SNYK-LINUX-APT-116518",
  "0/Vulnerabilities/0/References/6": "https://ubuntu.com/security/CVE-2011-3374",
  "0/Vulnerabilities/0/PublishedDate": "2019-11-26T00:15:00Z",
  "0/Vulnerabilities/0/LastModifiedDate": "2021-02-09T16:08:00Z",
  "0/Vulnerabilities/1/VulnerabilityID": "CVE-2019-18276",
  "0/Vulnerabilities/1/PkgName": "bash",
[...]
```
{% endraw %}

# Listing vulnerabilities

Trivy supports extracting parts of its report thanks to [Go templates](https://pkg.go.dev/text/template), so, for example, we can only display only the vulnerability levels and aggregate them:

{% raw %}
```
% docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v trivy-cache:/root/.cache/ aquasec/trivy -q i -f template -t '{{range .}}{{range .Vulnerabilities}}{{.Severity}}{{"\n"}}{{end}}{{end}}' python:3 | sort | uniq -c
     14 CRITICAL
    215 HIGH
   1187 LOW
    315 MEDIUM
```
{% endraw %}

*(Just for fun, we could rewrite the parsing using trivy's JSON output and [pjy](https://gitlab.com/hydrargyrum/pjy) to count severity occurrences: `docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v trivy-cache:/root/.cache/ aquasec/trivy -q i -f json python:3 | pjy '{severity: len(list(occurrences)) for severity, occurrences in imp("itertools").groupby(sorted(d[0].Vulnerabilities | _.Severity))}'`)*

So, that's a lot of known vulnerabilities.

# Existing fixes for some vulns

Since the `python:3` image is based on Debian, let's see how many have fixes in Debian:

{% raw %}
```
% docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v trivy-cache:/root/.cache/ aquasec/trivy -q i -f template -t '{{range .}}{{range .Vulnerabilities}}{{if .FixedVersion}}{{.Severity}}{{"\n"}}{{end}}{{end}}{{end}}' python:3 | sort | uniq -c
     10 HIGH
```
{% endraw %}

There are known fixes for 10 of the HIGH issues.

What are the vulnerable packages that could be fixed?

{% raw %}
```
% docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v trivy-cache:/root/.cache/ aquasec/trivy -q i -f template -t '{{range .}}{{range .Vulnerabilities}}{{if .FixedVersion}}{{.PkgName}}: {{.FixedVersion}}{{"\n"}}{{end}}{{end}}{{end}}' python:3
krb5-multidev: 1.17-3+deb10u2
libgssapi-krb5-2: 1.17-3+deb10u2
libgssrpc4: 1.17-3+deb10u2
libk5crypto3: 1.17-3+deb10u2
libkadm5clnt-mit11: 1.17-3+deb10u2
libkadm5srv-mit11: 1.17-3+deb10u2
libkdb5-9: 1.17-3+deb10u2
libkrb5-3: 1.17-3+deb10u2
libkrb5-dev: 1.17-3+deb10u2
libkrb5support0: 1.17-3+deb10u2
```
{% endraw %}

Let's see if those fixes are actually installed in a container running that image:

{% raw %}
```
% docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v trivy-cache:/root/.cache/ aquasec/trivy -q i -f template -t '{{range .}}{{range .Vulnerabilities}}{{if .FixedVersion}}{{.PkgName}}{{"\n"}}{{end}}{{end}}{{end}}' python:3 > fixed-packages.txt
% docker run --rm python:3 dpkg -l | grep -F "$(cat fixed-packages.txt)"
ii  krb5-multidev:amd64                1.17-3+deb10u1               amd64        development files for MIT Kerberos without Heimdal conflict
ii  libgssapi-krb5-2:amd64             1.17-3+deb10u1               amd64        MIT Kerberos runtime libraries - krb5 GSS-API Mechanism
ii  libgssrpc4:amd64                   1.17-3+deb10u1               amd64        MIT Kerberos runtime libraries - GSS enabled ONCRPC
ii  libk5crypto3:amd64                 1.17-3+deb10u1               amd64        MIT Kerberos runtime libraries - Crypto Library
ii  libkadm5clnt-mit11:amd64           1.17-3+deb10u1               amd64        MIT Kerberos runtime libraries - Administration Clients
ii  libkadm5srv-mit11:amd64            1.17-3+deb10u1               amd64        MIT Kerberos runtime libraries - KDC and Admin Server
ii  libkdb5-9:amd64                    1.17-3+deb10u1               amd64        MIT Kerberos runtime libraries - Kerberos database
ii  libkrb5-3:amd64                    1.17-3+deb10u1               amd64        MIT Kerberos runtime libraries
ii  libkrb5-dev:amd64                  1.17-3+deb10u1               amd64        headers and development libraries for MIT Kerberos
ii  libkrb5support0:amd64              1.17-3+deb10u1               amd64        MIT Kerberos runtime libraries - Support library
```
{% endraw %}

So, even though Debian has pushed a `1.17-3+deb10u2` version of all those packages, the `python:3` image does not ship them and uses vulnerable versions.

# A cheap workaround

Can this be trivially improved with an el-cheapo workaround?
Let's create a `Dockerfile` starting with the `python:3` image and then do updates.

{% raw %}
```
% cat > Dockerfile << EOF
FROM python:3
RUN apt-get update && apt-get upgrade --yes --no-install-recommends
EOF
% docker build --pull -t my-safe-python:3 - < Dockerfile
[...]
```
{% endraw %}

Let's verify installed packages:

{% raw %}
```
% docker run --rm my-safe-python:3 dpkg -l | grep -F "$(cat fixed-packages.txt)"
ii  krb5-multidev:amd64                1.17-3+deb10u2               amd64        development files for MIT Kerberos without Heimdal conflict
ii  libgssapi-krb5-2:amd64             1.17-3+deb10u2               amd64        MIT Kerberos runtime libraries - krb5 GSS-API Mechanism
ii  libgssrpc4:amd64                   1.17-3+deb10u2               amd64        MIT Kerberos runtime libraries - GSS enabled ONCRPC
ii  libk5crypto3:amd64                 1.17-3+deb10u2               amd64        MIT Kerberos runtime libraries - Crypto Library
ii  libkadm5clnt-mit11:amd64           1.17-3+deb10u2               amd64        MIT Kerberos runtime libraries - Administration Clients
ii  libkadm5srv-mit11:amd64            1.17-3+deb10u2               amd64        MIT Kerberos runtime libraries - KDC and Admin Server
ii  libkdb5-9:amd64                    1.17-3+deb10u2               amd64        MIT Kerberos runtime libraries - Kerberos database
ii  libkrb5-3:amd64                    1.17-3+deb10u2               amd64        MIT Kerberos runtime libraries
ii  libkrb5-dev:amd64                  1.17-3+deb10u2               amd64        headers and development libraries for MIT Kerberos
ii  libkrb5support0:amd64              1.17-3+deb10u2               amd64        MIT Kerberos runtime libraries - Support library
% docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v trivy-cache:/root/.cache/ aquasec/trivy -q i -f template -t '{{range .}}{{range .Vulnerabilities}}{{.Severity}}{{"\n"}}{{end}}{{end}}' my-python-safe:3 | sort | uniq -c
     14 CRITICAL
    205 HIGH
   1187 LOW
    315 MEDIUM
```
{% endraw %}

Only 205 HIGH-severity instead of 215 previously! Still 14 CRITICAL ones! At least we're a little bit better than we were.

# Rebuilding

An image is a snapshot. If tomorrow, Debian releases updates for those vulnerabilities, the `my-python-safe:3` image we built today will not contain them.
Rebuilding the image tomorrow should then take fresh updates from Debian and install them.

Should it?

Unfortunately, Docker caches images and rebuilds them [only if some conditions are met](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#leverage-build-cache):
- the base image has changed (but the base image is cached too! Don't forget to pass `--pull` to `docker-build` to let it check DockerHub)
- files from the context directory that are referenced to by `ADD`/`COPY` instructions change (in our case, there are none)
- the `Dockerfile` changes (in our case, it doesn't)

So, the changes we want to embed in the rebuilt image are in Debian's apt repositories, but `docker-build` does not watch this, it will not rebuild the image and in particular not re-execute the `RUN apt-get update ...` part.

Adding `--no-cache` flag to [`docker-build`](https://docs.docker.com/engine/reference/commandline/build/) will fix this issue, though it will redownload the same packages everytime, even when there aren't additional fixes.

## Tricking it
*Warning: the following is not a best practise and has shortcomings.*

We can get rid of the annoying `--no-cache` flag.

When the `ADD` instruction is given a URL, it will be run everytime, and depending on the downloaded content, the cache will be reused or invalidated.
This can be used to our advantage by setting a URL that is bound to Debian's updates. Let's take the smallest file: the `Release.gpg` which is tied to security updates.

Our Dockerfile becomes:

```
% cat > Dockerfile << EOF
FROM python:3
ADD http://security.debian.org/debian-security/dists/stable/updates/Release.gpg /tmp/security-snapshot-Release.gpg
RUN apt-get update && apt-get upgrade --yes --no-install-recommends
EOF
```

Thus, everytime we rebuild our image, the `Release.gpg` will be redownloaded. If there are new security updates, the downloaded file is different, and so the next instructions will be re-run, fetching the latest security updates:

```
% docker build --pull -t my-safe-python:3 - < Dockerfile
Sending build context to Docker daemon  2.048kB
Step 1/3 : FROM python:3.9
3.9: Pulling from library/python
Digest: sha256:acb4e43d0c66c168e72ceaba5913cde472e4a17017cec9346969c9725a1fea94
Status: Image is up to date for python:3.9
 ---> cba42c28d9b8
Step 2/3 : ADD http://security.debian.org/debian-security/dists/stable/updates/Release.gpg /tmp/debian-build-snapshot-Release.gpg
Downloading [==================================================>]  1.601kB/1.601kB
 ---> Using cache
 ---> 4d2061bff986
Step 3/3 : RUN apt-get update && apt-get upgrade --yes --no-install-recommends
 ---> Using cache
 ---> 6ad2d8fab15d
Successfully built 6ad2d8fab15d
Successfully tagged my-safe-python:3
```

However, this may rebuild the image when there are security updates even though it's for packages that aren't even installed.
So it may still rebuild the image a little too often.

# Other base images

Non-Debian-based images have similar problems.

For Alpine-based images, similar tests can be done:
- use `apk update && apk upgrade` to download security fixes
- use `apk list -I` to list installed packages

For example, applying a similar technique yields these results:
{% raw %}
```
% docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v trivy-cache:/root/.cache/ aquasec/trivy -q i -t '{{range .}}{{range .Vulnerabilities}}{{.Severity}}{{"\n"}}{{end}}{{end}}' -f template shaarli/shaarli:stable | sort | uniq -c
      7 CRITICAL
     13 HIGH
      5 LOW
     34 MEDIUM
      1 UNKNOWN
% docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v trivy-cache:/root/.cache/ aquasec/trivy -q i -t '{{range .}}{{range .Vulnerabilities}}{{.Severity}}{{"\n"}}{{end}}{{end}}' -f template my-safe-shaarli:stable | sort | uniq -c
      5 CRITICAL
     10 HIGH
      2 LOW
     16 MEDIUM
```
{% endraw %}

# About example reproducibility

If you run those examples, keep in mind that the versions are not pinned in the above snippets, to show the freshest results and the latest fixes, at the time of writing this post. But on the other hand, this means you might get different results and versions.
Even if pinning versions, examples cannot be made fully reproducible, because more vulnerabilities will be added to the trivy database with time, and we can't pin a trivy database version.

Also, make sure to run `docker pull IMAGENAME` to get the freshest versions from DockerHub, not a version cached locally long ago.

