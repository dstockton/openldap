# openldap mirror

Mirrors `cleanstart/openldap` from Docker Hub to GitHub Container Registry, hourly.

## Tags

| Tag | Meaning |
|-----|---------|
| `2.6.11` | Exact patch version |
| `2.6` | Latest patch in the 2.6 series (rolling) |
| `2` | Latest in the 2.x line (rolling) |

All three tags point to the same image digest. No `latest` tag is published.

## Usage

```sh
docker pull ghcr.io/dstockton/openldap:2.6
```

## How it works

A GitHub Action runs hourly, compares the upstream digest with GHCR, and uses
[crane](https://github.com/google/go-containerregistry/tree/main/cmd/crane)
to do a registry-to-registry copy (no rebuild, multi-arch preserved).
