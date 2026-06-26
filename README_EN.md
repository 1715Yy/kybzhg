# kybzhg

Personal Nezha dashboard deployment scripts via Argo tunnel, supports v0 / v1.

## Deploy

```bash
bash <(wget -qO- https://raw.githubusercontent.com/1715Yy/kybzhg/main/dashboard.sh)
```

Docker image:

```
ghcr.io/1715yy/kybzhg:latest
```

## Notes

- Backup excludes `data/tsdb/` by default, ~3MB per snapshot
- Auto-update source is pinned to this repo
- No issues / PRs accepted
