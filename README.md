# ansible-role-fluentd

Install fluentd

# Requirements

None

# Role Variables

| variable | description | default |
|----------|-------------|---------|
| fluentd\_config\_dir          | path to conf.d directory | "{{ \_\_fluentd\_config\_dir }}" |
| fluentd\_config\_path         | path to fluent.conf | "{{ \_\_fluentd\_config\_path }}" |
| fluentd\_service\_name        | service name | fluentd |
| fluentd\_gem\_bin             | path to fluent-gem  | "{{ \_\_fluentd\_gem\_bin }}" |
| fluentd\_plugins\_to\_install | plugins to install | [] |
| fluentd\_configs              | hash of config fragments, see below | {} |
| fluentd\_certs\_dir           | directory where cert files locate | "{{ \_\_fluentd\_certs\_dir }}" |
| fluentd\_ca\_key              | content of ca\_key.pem | "" |
| fluentd\_ca\_cert             | content of ca\_cert.pem | "" |
| fluentd\_buffer\_path         | path to file-based buffer directory | /var/spool/fluentd |
| fluentd\_unix\_pipe\_dir      | path to directory where AF\_UNIX pipe should be created | {{ \_\_fluentd\_unix\_pipe\_dir }} |

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

Key is the name of the config fragment. the key has a hash described below.

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
