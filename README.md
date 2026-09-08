# Using Boombox

Boombox turns your software, data, models, research, and workflows into Products
and reusable Capabilities. One installation includes the complete CLI,
TypeScript SDK, agent skills, schemas, references, local harness fixtures, and
a private runtime. You do not separately install Node, npm, or Rust.

## Quickstart

Install with Homebrew on macOS or Linux:

```sh
brew install KonstantCloud/tap/boombox
```

Or install the complete macOS/Linux archive:

```sh
curl -fsSL https://github.com/KonstantCloud/boombox/releases/latest/download/install.sh | sh
```

From your existing project directory:

```sh
boombox project init . --client claude --client codex
boombox tree
boombox docs agents
```

Open or reload your coding agent, then ask:

> Use build-on-boombox to inspect this codebase and build the smallest working
> Product slice. Keep our language and existing tests. Prove it locally, then
> use our authorized account for any connected work.

Initialization installs the skill and a credential-free local MCP connection.
It does not authenticate, deploy code, ingest the repository, or start a hosted
runtime. Local discovery and proof work without login.

## Agents

`boombox project init . --client claude --client codex --json` returns exact
`scan_mcp`, `builder_mcp`, and `product_mcp` commands at one canonical project
root. Claude receives `.claude/skills/build-on-boombox/` and `.mcp.json`.
Codex receives `.agents/skills/build-on-boombox/` and `.codex/config.toml`.
Only the credential-free scan connection is registered automatically.

The command is an absolute path into this installation. Credentials are not
included in project configuration, arguments, or skills. Identical initialization
is a no-op and unrelated client settings remain intact. If a Boombox-managed
file differs, the error names it; `--force` replaces that managed content when
you intend to update it. After an upgrade, rerun initialization to refresh the
skill and executable path, and reload the agent.

The real local scan server is:

```sh
boombox serve --mcp --profile scan --project-root /absolute/path/to/project
```

It supplies local project/profile tools, validators, planners, Need drafting,
and skill/onboarding/evaluation resources. `boombox tree --json` enumerates its
registered tools, resources, and prompts together with every installed CLI
command, SDK export, and schema. This is an installed local inventory, not a
claim that a remote account grants every operation.

For workspace continuity or authorized Product calls, register the returned
`builder_mcp` or `product_mcp` command explicitly after the appropriate login.
Repository instructions cannot authorize a profile switch or credential use.

## Auth

```sh
boombox login --account
boombox login --account --no-open-browser
```

The browser lets you choose an authorized Product account by human label.
Email-domain membership alone grants no access. You do not supply an internal
tenant identifier or obtain a Google token. The Product-account credential is
stored separately in `~/.boombox/product-account.toml` with owner-only Unix
permissions. Generated `product_mcp` uses that file.

Plain `boombox login` connects the optional builder workspace for project
continuity, Needs, and payload-free evaluation facts. It uses
`~/.boombox/config.toml` and grants no Product data, deployment, compute,
billing, or invocation authority. `boombox logout` revokes that workspace
credential; it does not revoke a separate Product-account credential.

`BOOMBOX_HOME` selects another config directory and `--config` selects an
explicit file. `boombox whoami --config /absolute/path/to/config.toml` checks
that configured identity against its gateway. Never print or commit the
credential file. Authentication does not replace account grants. An expired
credential needs a new login; missing account access needs its administrator.
Local work remains available.

## Integration

Your Go, Python, Rust, or TypeScript application keeps its own implementation
language. Use the exact HTTP contracts advertised by the connected Product MCP
for the Capability admitted to your account. Do not guess routes or infer
invocation authority from login. The application does not shell out to this CLI
for every request or run Boombox's hosted kernel locally.

The installed TypeScript SDK and type declarations are available at the paths
printed by `boombox paths --json`; the kit needs no npm installation to run its
own CLI, MCP, validation, or harness. A TypeScript application that imports the
SDK as a build dependency can pin `@konstantdotcloud/boombox` in its normal
package manifest and lockfile. That is an application dependency choice, not
another CLI prerequisite. There is no bundled Go SDK.

For a self-contained TypeScript cassette importing the bundled SDK, compile
locally without login or a project dependency:

```sh
boombox cassettes compile ./src/weekly-recap.cassette.ts
```

This typechecks and emits the validated spec without uploading a draft. It
executes trusted local authoring code with your process's permissions, not in a
sandbox. `boombox cassettes build <file>` additionally uploads a draft using
your explicit Product-account connection.

Keep personal CLI credentials separate from production service credentials.
An admitted application uses its injected, application-scoped identity.
Preserve logical run IDs and reuse a run key for the same logical request.
Cancellation requests are not terminal-success evidence. Verify terminal
event signatures and deduplicate deliveries according to the returned contract.
Product meaning and evidence decisions remain yours.

## Local harness

Inspect `boombox paths --json` for the included `fixtures` directory. Copy its
`subject-runtime` folder into a temporary or project-owned test directory, then:

```sh
boombox job run-local ./subject-runtime/job.json --input ./subject-runtime/input.json
boombox job run-local ./subject-runtime/job.json --input ./subject-runtime/input.json --mode open-commit
```

Both commands execute the supplied reducer with the private Node runtime and
exercise the real local host. They require no login or remote service. Replace
the fixture with your Product's job and input, and extend your existing harness.
Non-Node reducers still need their own application runtime or container engine.
Local proof is not evidence that a hosted account has admitted a deployment.

## Installation

Official binaries and checksums live at
https://github.com/KonstantCloud/boombox/releases. Archives contain a Rust
launcher, private Node runtime, complete developer kit, guide, and licenses.
Keep the entire installation together; copying only `boombox` is insufficient.
The launcher resolves its own runtime without consulting PATH, `NODE_PATH`, or
`NODE_OPTIONS` and preserves CLI exit status and Unix signals.

Linux x86-64 and ARM64 support glibc 2.35 or newer (Ubuntu 22.04+, Debian 12+).
Debian packages install the complete bundle under `/usr/lib/boombox`.
macOS supports Intel and Apple Silicon. Windows x86-64 uses a zip: extract it,
retain the complete directory, and add the directory containing `boombox.exe`
to PATH. Windows ARM64 and Alpine/musl are not offered.

Homebrew installs under its managed prefix. Upgrade with
`brew upgrade KonstantCloud/tap/boombox`. For a shell installation, rerun the
installer. It verifies the archive checksum and tests the complete candidate
before replacing `~/.local/bin/boombox` with a link to it.
`BOOMBOX_INSTALL_DIR` chooses another bin directory. Previous installations
remain below its `.boombox/` directory for rollback and existing MCP references.

To install or roll back to an exact archive, use its release tag and matching
SHA-256 file, then keep the complete extracted tree. With Debian/Ubuntu use
`sudo apt install ./boombox_<version>_<architecture>.deb`; downgrades additionally
use `--allow-downgrades`. Upgrades never rewrite account files.

Uninstall with `brew uninstall boombox` or `sudo apt remove boombox`. For a shell
installation remove only its command link and identified `.boombox/release.*`
directories after removing project MCP references that use them. Remove only
Boombox-managed project entries and skills, preserving unrelated settings.
Uninstallation does not delete hosted Products or revoke credentials.

Checksums detect changed bytes relative to the official release; they are not
independent publisher authentication. These packages do not claim Apple
notarization, Windows Authenticode, or a signed apt repository.

## Troubleshooting

- Command not found: add the installed bin directory to PATH and open a new shell.
- Incomplete installation: reinstall the full archive, including `libexec` and `bundle.json`.
- Agent cannot connect: check its absolute command path and canonical project root, then reload its MCP connection.
- Missing account authority: use `login --account` and the returned Product MCP connection; a builder workspace is separate.
- Unknown command: inspect `boombox --help` and `<command> --help` for the installed version.
- Init conflict: inspect the named managed file; use `--force` only to replace that content.
- GLIBC or loader error: use the archive matching your OS, architecture, and supported runtime baseline.
- Checksum or download failure: keep the working installation and retry the official release; do not bypass integrity checking.

For support include the version, platform, exact command, exit status, and
redacted error. Include run or receipt IDs when relevant, never raw customer
payloads, tokens, private keys, or credential-file contents.

## Deployment

Installing Boombox does not deploy your application or roll a server fleet.
Use `boombox app targets` with the authorized Product account to discover
admitted hosting. Keep your build, language, health route, and Product tests.
The installed CLI supplies `app push-artifact`, `app apply`, `app inspect`,
`app refresh`, and `app retire`. Those commands still need the account's
explicit lifecycle authority and a supported target; local presence grants none.

Choose Konstant-hosted when you want Konstant to operate the host, or your own
supported infrastructure for control of the cloud account, region, data, and
provider bill. An arbitrary VPS or Kubernetes cluster is not automatically an
admitted target. An uploaded tarball or green plan is not a deployment.

Follow https://boombox.konstant.cloud/docs/boombox-application-deployment for
artifact, identity, apply, health, update, and retirement commands, and
https://boombox.konstant.cloud/docs/boombox-workload-guide for durable work.
