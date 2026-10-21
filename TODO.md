# TODO

Known issues and planned work. Items marked **bug** were found by reading the code and haven't been fixed yet.

## Bugs

- [ ] **bug: Twingate tokens are swapped.** `3-interactive-generator/templates/runcmd/twingate.yaml` sets `TWINGATE_ACCESS_TOKEN="__TW_RT__"` and `TWINGATE_REFRESH_TOKEN="__TW_AT__"`. Swap the placeholders so access → `__TW_AT__` and refresh → `__TW_RT__`.
- [ ] **bug: the node_exporter install doesn't work as written.** Every item in `templates/runcmd/monitoring.yaml` is its own `bash -c`, so `BASE`, `ASSET` and `DIR` are gone by the next step. Put the download, extract and install steps into one `bash -c` block (or a script under `write_files`).
- [ ] **bug: output lands under `$PWD/output`, not under the script's folder.** `setup_output_dir` in `lib/helpers.sh` uses `OUT_BASE="${OUT_BASE:-./output}"`, so running the script from another directory writes there. Default it to `$SCRIPT_DIR/output`.
- [ ] **bug: the `https-token` ArgoCD auth branch can't be reached.** `get_argocd_runcmd` handles `https-token`, but the `select` menu in `setup_argocd` never offers it, and nothing sets `GITHUB_USERNAME`/`GITHUB_TOKEN`. Either add it to the menu with prompts or delete the branch.
- [ ] The ApplicationSet guard in `lib/argocd.sh` (`!= https-public || -n REPO_URL`) is always true once a repo URL is set. Simplify it or fix the intent.
- [ ] `generate_gitops_templates` says "Copy the example templates from the documentation above", but no example templates exist. Add an example `applications.yaml` to the docs.

## Improvements

- [ ] ArgoCD hostname is hard-coded to `argocd.octolet.int` (`templates/runcmd/argocd.yaml`). Prompt for it.
- [ ] ArgoCD installs from `refs/heads/master`. Pin it to a release tag.
- [ ] ArgoCD TLS is a self-signed cert generated on the node. Consider cert-manager.
- [ ] Prompt for the timezone and the default user (both fixed in `cloud-init-base.yaml`: `Etc/UTC`, `ubuntu`).
- [ ] Add a non-interactive mode (env vars or a config file) so the generator can be scripted.
- [ ] Add CI: `shellcheck` on `lib/*.sh` and `make-user-data-v3.sh`, plus `yamllint` on `templates/` and a sample generated `user-data`. There are no GitHub Actions workflows yet.
- [ ] Bring `2-static-configs/` in line with what the generator produces now (provision report, monitoring, ArgoCD).
- [ ] `1-packer-automation/`: still a placeholder. Build the Packer template.
