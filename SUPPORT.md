# Support

LabFox is an unofficial third-party GitLab client, maintained by a single maintainer. This document
explains where to ask for help and what can realistically be answered.

## Start With the Documentation

Read the [README](README.md) first — it covers what LabFox is, the planned 1.0 scope, and the
roadmap. For contribution questions, read [CONTRIBUTING.md](CONTRIBUTING.md).

The project is in early development and **there is no runnable build yet**. There is nothing to
install and nothing to download, so support for setting the app up is limited to the repository
itself. Questions about running the app on your machine will mostly be answered with "not yet".

## Asking a Question

1. Search the [existing issues](https://github.com/labfox-app/labfox/issues), including closed ones.
2. If nothing matches, open a new issue using the provided issue forms rather than a blank issue.
   The forms ask for the information needed to act on a report.
3. Contributor pull requests target the `dev` branch. `main` holds releases and is updated only
   through separate reviewed `dev` -> `main` release pull requests.

## Never Paste Credentials or Private Data Into an Issue

GitHub issues are public and permanent. Before pasting anything, redact:

- GitLab Personal Access Tokens (`glpat-...`), OAuth access tokens, and refresh tokens
- `Authorization` headers and any other raw credential material
- self-hosted GitLab instance hostnames and internal URLs
- private source code, diffs, and raw API responses
- job logs, which frequently contain tokens, internal hostnames, and employer-confidential data
- screenshots, which leak all of the above without anyone noticing

Replace real values with placeholders (`glpat-REDACTED`, `gitlab.example.com`). Trim logs down to
the lines that actually show the problem. If you post a token by mistake, revoke it in GitLab
immediately — deleting the comment is not enough.

## Security Issues

Do not report suspected vulnerabilities through public issues. Follow [SECURITY.md](SECURITY.md).

## What Maintainers Can Help With

- reproducible bugs in the current codebase, with clear steps and the commit or branch you used
- scoped discussion of a contribution before you write the code
- questions about the documented 1.0 scope and whether an idea fits inside it

## What Maintainers Cannot Help With

- GitLab server administration, upgrades, or instance configuration
- GitLab account, group, or permission problems
- corporate network setup: proxies, VPNs, firewalls, custom CA certificates
- third-party Flutter, Dart, or IDE tooling problems unrelated to this repository
- feature requests outside the documented 1.0 scope

LabFox is not a GitLab Inc. product and its maintainers cannot act on your GitLab installation or
account. Direct GitLab product, server, and account questions to
[GitLab's own support channels](https://about.gitlab.com/support/).
