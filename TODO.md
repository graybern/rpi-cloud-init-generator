# TODO

Known issues and planned work.

## Bugs / cleanup

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
