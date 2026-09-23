# openldap mirror

Mirrors `cleanstart/openldap` from Docker Hub to GitHub Container Registry, hourly.


## Tags

| Tag | Meaning |
|-----|---------|
| `2.7.1` | Exact patch version |
| `2.7` | Latest patch in the 2.7 series (rolling) |
| `2` | Latest in the 2.x line (rolling) |

All three tags point to the same image digest. No `latest` tag is published.

Upstream dropped its 2.6.x tags on 2026-09-23. The `2.6` and `2.6.x` tags here
stay frozen at 2.6.13. Pin one of those if you are not ready for 2.7.

## Usage

```sh
docker pull ghcr.io/dstockton/openldap:2.7
```

## How it works

A GitHub Action runs hourly, picks the highest `2.x.y` tag upstream, compares
its digest with GHCR, and uses
[crane](https://github.com/google/go-containerregistry/tree/main/cmd/crane)
to do a registry-to-registry copy (no rebuild, multi-arch preserved).

The series is derived from the tag rather than hardcoded, so an upstream bump
to 2.8 is picked up without a code change. A move to 3.x is not, by design:
the job fails and says so, so that is a deliberate decision.
