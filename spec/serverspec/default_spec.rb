require 'spec_helper'
require 'serverspec'

fluentd_package_name = 'fluentd'
fluentd_service_name = 'fluentd'
fluentd_config       = '/etc/fluentd/fluentd.conf'
fluentd_user_name    = 'fluentd'
fluentd_user_group   = 'fluentd'
fluentd_work_dir     = '/var/spool/fluentd'
fluentd_gem_bin      = '/usr/bin/fluent-gem'

os_default_syslog_service_name = 'syslogd'

case os[:family]
when 'freebsd'
  fluentd_package_name = 'rubygem-fluentd'
  fluentd_service_name = 'fluentd'
  fluentd_config_path  = '/usr/local/etc/fluentd/fluent.conf'
  fluentd_config_dir   = '/usr/local/etc/fluentd/conf.d'
  fluentd_user_name    = 'root'
  fluentd_user_group   = 'wheel'
  fluent_gem_bin       = '/usr/local/bin/fluent-gem'
end

describe package(fluentd_package_name) do
  it { should be_installed }
end 

describe file(fluentd_config_dir) do
  it { should be_directory }
  it { should be_mode 755 }
end

describe service(fluentd_service_name) do
  it { should be_running }
  it { should be_enabled }
end

describe command("#{fluent_gem_bin} list") do
  its(:stdout) { should match /fluent-plugin-redis/ }
  its(:stdout) { should match /fluent-plugin-secure-forward/ }
end
