# Agent Guidelines for Pinchflat

This document provides context and guidelines for AI agents working on this codebase.

## Project Overview

Pinchflat is an Elixir/Phoenix application for self-hosted media management. It uses:

- **Backend**: Elixir 1.17+, Phoenix 1.7, Ecto with SQLite
- **Frontend**: Phoenix LiveView, Tailwind CSS, esbuild
- **Background Jobs**: Oban
- **Containerization**: Docker with multi-arch support (amd64/arm64)

## Development Environment

This project uses Nix flakes for reproducible development environments.

```bash
# Enter dev shell
nix develop

# Or with specific shell
nix develop . --command fish
```

### Available Tools (via flake.nix)

- `lefthook` - Git hooks manager
- `actionlint` - GitHub Actions linter
- `typos` - Spell checker
- `prettier` - Code formatter (JS/CSS/YAML/JSON)
- `cocogitto` - Conventional commits
- `just` - Command runner
- Docker tooling (docker, docker-buildx, docker-compose)

## Git Hooks (lefthook)

Pre-commit hooks are configured in `lefthook.yml`:

| Hook         | Files                                     | Purpose             |
| ------------ | ----------------------------------------- | ------------------- |
| `prettier`   | `*.{css,html,js,json,md,mjs,ts,yaml,yml}` | Format check        |
| `mix format` | `*.{ex,exs}`                              | Elixir formatting   |
| `typos`      | All staged files                          | Spell checking      |
| `actionlint` | `.github/workflows/*.{yml,yaml}`          | Validate GH Actions |

### Bypassing Hooks

If hooks fail due to environment issues (e.g., permission errors):

```bash
git commit --no-verify -m "message"
```

## GitHub Actions Workflows

### `lint_and_test.yml`

Runs on PRs and pushes to master. Uses Docker Compose for testing.

Key features:

- Concurrency control (cancels in-progress runs on same PR)
- 30-minute timeout
- Pinned action versions (SHA-based for security)

### `docker_release.yml`

Builds and pushes Docker images to GHCR.

**Architecture**:

```
prepare job (determines platform matrix)
    |
    v
build job (parallel)
├── linux/amd64 on ubuntu-latest (native)
└── linux/arm64 on ubuntu-24.04-arm (native, NOT QEMU)
    |
    v
merge job (creates multi-arch manifest)
```

**Trigger behavior**:

- Push to master: Builds amd64 only (fast dev iteration)
- Release published: Builds both amd64 and arm64
- workflow_dispatch: User chooses platforms

**Important**: GHCR requires lowercase repository names. The workflow converts `$GITHUB_REPOSITORY` to lowercase using `${GITHUB_REPOSITORY,,}`.

## Releasing a New Version

1. Update version in `mix.exs`:

   ```elixir
   version: "YYYY.M.D",
   ```

2. Commit and tag:

   ```bash
   git add mix.exs
   git commit -m "chore: bump version to vYYYY.M.D"
   git tag vYYYY.M.D
   ```

3. Push to your fork:

   ```bash
   git push origin master && git push origin vYYYY.M.D
   ```

4. Create GitHub release:
   ```bash
   gh release create vYYYY.M.D --title "vYYYY.M.D" --generate-notes --repo <owner>/pinchflat
   ```

### Cleaning Up Tags

If you need to delete and recreate tags:

```bash
# Delete locally
git tag -d vX.Y.Z

# Delete on remote
git push origin --delete vX.Y.Z

# Recreate on specific commit
git tag vX.Y.Z <commit-sha>

# Force push to overwrite remote
git push origin vX.Y.Z --force
```

## Validating GitHub Actions Locally

Always validate workflow changes before pushing:

```bash
# Check all workflows
actionlint

# Check specific file
actionlint .github/workflows/docker_release.yml
```

### Common Issues actionlint Catches

- Invalid YAML syntax
- Unknown/misspelled action inputs
- Type errors in expressions (`${{ }}`)
- Invalid `runs-on` values
- Shell script issues (via shellcheck)
- Deprecated features

### Shellcheck Directives

For intentional word splitting in workflows, add the directive inside the `run:` block:

```yaml
run: |
  # shellcheck disable=SC2046
  docker buildx imagetools create $(jq -cr '...' <<< "$JSON") \
    $(printf 'image@sha256:%s ' *)
```

## CI Best Practices

1. **Pin action versions to SHAs** for security:

   ```yaml
   uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
   ```

2. **Quote shell variables** to satisfy shellcheck:

   ```yaml
   run: echo "value" >> "$GITHUB_OUTPUT"
   ```

3. **Use native ARM runners** instead of QEMU for faster builds:

   ```yaml
   runs-on: ubuntu-24.04-arm # Native ARM64
   ```

4. **Scope caches by platform** to avoid conflicts:

   ```yaml
   cache-from: type=gha,scope=build-linux-amd64
   ```

5. **Add concurrency controls** to save CI minutes:
   ```yaml
   concurrency:
     group: ${{ github.workflow }}-${{ github.head_ref || github.run_id }}
     cancel-in-progress: true
   ```

## Running Tests

```bash
# Via Docker Compose (as CI does)
docker compose -f docker-compose.ci.yml up -d
docker compose exec phx mix deps.get
docker compose exec phx mix ecto.create
docker compose exec phx mix ecto.migrate
docker compose exec phx mix check --no-fix --no-retry
```

## Code Style

- Elixir: Follow `mix format` (configured in `.formatter.exs`)
- JavaScript/CSS: Follow Prettier (configured in `.prettierrc.js`)
- Commits: Conventional commits recommended (cocogitto installed)
