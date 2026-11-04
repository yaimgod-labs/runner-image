# runner-image

The runner image for god-server's self-hosted GitHub Actions runners. It's GitHub's official `ghcr.io/actions/actions-runner`, plus the GitHub CLI (`gh`) and the latest Ubuntu security fixes.

- **Built here only**, by `.github/workflows/build.yml` on GitHub's machines (`ubuntu-latest`). It is never built on the server.
- **Every build:** a smoke test (`gh` and the runner start as uid 1001), then a Trivy scan, which fails on fixable HIGH/CRITICAL in OS packages. Pushes to `main` then push `ghcr.io/yaimgod-labs/runner-image:<runner>-gh<gh>` and `:latest`, and record a provenance attestation for the digest.
- **Weekly rebuild** (Mondays) picks up Ubuntu fixes. Dependabot opens PRs for new runner releases (the `FROM` line) and action updates. To move `gh`: change `GH_VERSION` and `GH_SHA256` together.
- **The server** accepts an image only through `sudo bash ~/hardening/runners/4-update.sh --image <ref>`. That script checks the digest, the attestation (it must come from `build.yml` on `main` of this repo), the runner and `gh` versions, and the user. Each build's summary prints the exact line to run.

This repo is **public**, so the server can pull the image without a token. It contains nothing secret. Public repos can't use the self-hosted runners, and this one doesn't need to.

To check an image's signature yourself (from a machine with `gh`):

```bash
gh attestation verify oci://ghcr.io/yaimgod-labs/runner-image:<tag> -R yaimgod-labs/runner-image
```
