# ansible-role-fluentd

Install fluentd

# Requirements

None

# Role Variables

| variable | description | default |
|----------|-------------|---------|
| `fluentd_user`                | the user of `fluentd` | `{{ __fluentd_user }}` |
| `fluentd_group`               | the group of `fluentd` | `{{ __fluentd_group }}` |
| `fluentd_package_name`        | package name of `fluentd` | `{{ __fluentd_package_name }}` |
| `fluentd_config_dir`          | path to `conf.d` directory | `{{ __fluentd_config_dir }}` |
| `fluentd_config_path`         | path to `fluent.conf` | `{{ __fluentd_config_path }}` |
| `fluentd_service_name`        | service name of `fluentd` | `{{  __fluentd_service_name }}` |
| `fluentd_gem_bin`             | path to `fluent-gem`  | `{{ __fluentd_gem_bin }}` |
| `fluentd_plugins_to_install`  | list of plug-in names to install | `[]` |
| `fluentd_certs_dir`           | path to directory where cert files reside | `{{ __fluentd_certs_dir }}` |
| `fluentd_configs`             | dict of config fragments, see below | {} |
| `fluentd_ca_key`              | content of `ca_key.pem` | "" |
| `fluentd_ca_cert`             | content of `ca_cert.pem` | "" |
| `fluentd_ca_private_key_passphrase` | the passphrase of `ca_key.pem` | "" |
| `fluentd_buffer_path`         | path to file-based buffer directory | `/var/spool/fluentd` |
| `fluentd_unix_pipe_dir`       | path to directory where `AF_UNIX` pipe should be created | `{{ __fluentd_unix_pipe_dir }}` |

# Dependencies

None

# Example Playbook

Including an example of how to use your role (for instance, with variables
passed in as parameters) is always nice for users too:

```yaml
- hosts: servers
  roles:
     - ansible-role-fluentd
  vars:
    fluentd_plugins_to_install:
      - fluent-plugin-redis
      - fluent-plugin-secure-forward
    fluentd_configs:
      listen_on_5140:
        enabled: true
        config: |
          <source>
            @type syslog
            port 5140
            bind 127.0.0.1
            tag syslog
          </source>
          <match syslog.**>
            @type null
          </match>
```

## fluentd\_configs

Key is the name of the config fragment file. the key has a hash described below.

| key     | value                                            |
|---------|--------------------------------------------------|
| enabled | bool, create the config if true, remove if false |
| config  | the configuration                                |

# License

```
Copyright (c) 2016 Tomoyuki Sakurai <tomoyukis@reallyenglish.com>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

# Author Information

Tomoyuki Sakurai <tomoyukis@reallyenglish.com>
