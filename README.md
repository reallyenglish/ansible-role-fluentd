ansible-role-fluentd
====================

Install fluentd

Requirements
------------

None

Role Variables
--------------

| variable | description | default |
|----------|-------------|---------|
| fluentd\_config\_dir | path to conf.d directory | "{{ \_\_fluentd\_config\_dir }}" |
| fluentd\_config\_path | path to fluent.conf | "{{ \_\_fluentd\_config\_path }}" |
| fluentd\_service\_name | service name | fluentd |
| fluentd\_gem\_bin | path to fluent-gem  | "{{ \_\_fluentd\_gem\_bin }}" |
| fluentd\_plugins\_to\_install | plugins to install | [] |

Dependencies
------------

None

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - ansible-role-fluentd
      vars:
        fluentd_plugins_to_install:
          - fluent-plugin-redis
          - fluent-plugin-secure-forward

License
-------

BSD

Author Information
------------------

Tomoyuki Sakurai <tomoyukis@reallyenglish.com>
