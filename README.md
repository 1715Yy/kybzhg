# kybzhg

Personal-use Nezha monitoring panel deployment script, based on Argo Tunnel, compatible with both v0 and v1 versions.

## 部署

```bash
bash <(wget -qO- https://raw.githubusercontent.com/1715Yy/kybzhg/main/dashboard.sh)
```

Docker 镜像：

```
ghcr.io/1715yy/kybzhg:latest
```

## 说明

- 备份默认排除 `data/tsdb/`，备份体积约 3MB
- 自动更新源已切到本仓库
- 不接受 issue / PR
