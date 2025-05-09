# cloud-init

![Version: 0.2.13](https://img.shields.io/badge/Version-0.2.13-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

A Helm chart that generates cloud-init config files

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| cloudymax |  |  |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| boot_cmd | list | `[]` | Run arbitrary commands early in the boot process See https://cloudinit.readthedocs.io/en/latest/reference/modules.html#bootcmd |
| ca_certs | list | `[]` | Add CA certificates See https://cloudinit.readthedocs.io/en/latest/reference/modules.html#ca-certificates |
| debug | bool | `false` | when enabled job sleeps to allow user to exec into the container |
| disable_root | bool | `false` | Disable root login over ssh |
| disk_setup | object | `{}` |  |
| envsubst | bool | `true` | Run envsubst against bootcmd and runcmd fields at the beginning of templating Not an official part of cloid-init |
| existingConfigMap | bool | `false` | Dont recreate script configmap. Set to true when keeping multiple cloud-init secrets in the same namespace |
| extraEnvVars | list | `[]` |  |
| fs_setup | list | `[]` |  |
| hostname | string | `"random"` | virtual-machine hostname |
| image | string | `"deserializeme/kv-cloud-init:v0.0.1"` | image version |
| mounts | list | `[]` | Set up mount points. mounts contains a list of lists. The inner list contains entries for an /etc/fstab line |
| namespace | string | `"kubevirt"` | namespace in which to create resources |
| network | object | `{"config":"disabled"}` | networking options |
| network.config | string | `"disabled"` | disable cloud-init’s network configuration capability and rely on other methods such as embedded configuration or other customisations. |
| package_reboot_if_required | bool | `false` | Update, upgrade, and install packages See https://cloudinit.readthedocs.io/en/latest/reference/modules.html#package-update-upgrade-install |
| package_update | bool | `true` |  |
| package_upgrade | bool | `false` |  |
| packages | list | `[]` |  |
| runcmd | list | `[]` | Run arbitrary commands See https://cloudinit.readthedocs.io/en/latest/reference/modules.html#runcmd |
| salt | string | `"saltsaltlettuce"` | salt used for password generation |
| secret_name | string | `"max-scrapmetal-user-data"` | name of secret in which to save the user-data file |
| serviceAccount | object | `{"create":true,"existingServiceAccountName":"cloud-init-sa","name":"cloud-init-sa"}` | Choose weather to create a service-account or not. Once a SA has been created you should set this to false on subsequent runs. |
| swap | object | `{"enabled":false,"filename":"/swapfile","maxsize":"1G","size":"1G"}` | creates a swap file using human-readable values. |
| users | list | `[{"groups":"users, admin, docker, sudo, kvm","lock_passwd":false,"name":"pool","password":{"random":true},"shell":"/bin/bash","ssh_authorized_keys":[],"ssh_import_id":[],"sudo":"ALL=(ALL) NOPASSWD:ALL"}]` | user configuration options See https://cloudinit.readthedocs.io/en/latest/reference/modules.html#users-and-groups do NOT use 'admin' as username - it conflicts with multiele cloud-images |
| users[0].password | object | `{"random":true}` | set user password from existing secret or generate random |
| users[0].ssh_authorized_keys | list | `[]` | provider user ssh pub key as plaintext |
| users[0].ssh_import_id | list | `[]` | import user ssh public keys from github, gitlab, or launchpad See https://cloudinit.readthedocs.io/en/latest/reference/modules.html#ssh |
| wireguard | list | `[]` | add wireguard configuration from existing secret or as plain-text See https://cloudinit.readthedocs.io/en/latest/reference/modules.html#wireguard |
| write_files | list | `[]` | Write arbitrary files to disk. Files my be provided as plain-text or downloaded from a url See https://cloudinit.readthedocs.io/en/latest/reference/modules.html#write-files |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
