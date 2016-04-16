require 'spec_helper'
require 'serverspec'

fluentd_package_name = 'fluentd'
fluentd_service_name = 'fluentd'
fluentd_config       = '/etc/fluentd/fluentd.conf'
fluentd_user_name    = 'fluentd'
fluentd_user_group   = 'fluentd'
fluentd_work_dir     = '/var/spool/fluentd'
fluentd_gem_bin      = '/usr/bin/fluent-gem'
fluentd_certs_dir    = '/etc/fluentd/certs'

case os[:family]
when 'freebsd'
  fluentd_package_name = 'rubygem-fluentd'
  fluentd_service_name = 'fluentd'
  fluentd_config_path  = '/usr/local/etc/fluentd/fluent.conf'
  fluentd_config_dir   = '/usr/local/etc/fluentd/conf.d'
  fluent_gem_bin       = '/usr/local/bin/fluent-gem'
  fluentd_certs_dir    = '/usr/local/etc/fluentd/certs'
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

describe file("#{fluentd_config_dir}/listen_on_5140.conf") do
  its(:content) { should match /@type syslog/ }
  its(:content) { should match /port 5140/ }
end

describe port(5140) do
  it { should be_listening }
end

describe file(fluentd_certs_dir) do
  it { should be_directory }
  it { should be_mode 755 }
end

describe file("#{fluentd_certs_dir}/ca_key.pem") do
  it { should be_file }
  its(:content) { should match Regexp.escape('eUVHk/0/haiey+uTvUVjLMG1uKqXEKzqbhuna3k+dPuOTOYPPrAArNfVgXS3K+rV') }
  it { should be_mode 440 }
  it { should be_owned_by fluentd_user_name }
  it { should be_grouped_into fluentd_user_group }
end

describe file("#{fluentd_certs_dir}/ca_cert.pem") do
  it { should be_file }
  its(:content) { should match /MIIDIDCCAggCAQEwDQYJKoZIhvcNAQEFBQAwTTELMAkGA1UEBhMCVVMxCzAJBgNV/ }
  it { should be_mode 644 }
  it { should be_owned_by fluentd_user_name }
  it { should be_grouped_into fluentd_user_group }
end
