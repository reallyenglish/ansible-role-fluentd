require "spec_helper"
require "serverspec"

fluentd_package_name = "td-agent"
fluentd_service_name = "td-agent"
fluentd_conf_dir     = "/etc/td-agent"
fluentd_config_dir   = "/etc/td-agent/conf.d"
fluentd_config_path  = "/etc/td-agent/td-agent.conf"
fluentd_user_name    = "td-agent"
fluentd_user_group   = "td-agent"
fluentd_gem_bin      = "/usr/sbin/td-agent-gem"
fluentd_certs_dir    = "/etc/td-agent/certs"
fluentd_buffer_dir   = "/var/spool/fluentd"
fluentd_unix_pipe_dir = "/var/tmp/fluentd"
fluentd_log_dir      = "/var/log/td-agent"
fluentd_log_file     = "#{fluentd_log_dir}/td-agent.log"
default_user         = "root"
default_group        = "root"
pid_dir_mode         = 755
extra_groups         = %w(tty bin)

case os[:family]
when "freebsd"
  fluentd_user_name    = "fluentd"
  fluentd_user_group   = "fluentd"
  fluentd_package_name = "rubygem-fluentd"
  fluentd_service_name = "fluentd"
  fluentd_config_path  = "/usr/local/etc/fluentd/fluent.conf"
  fluentd_conf_dir     = "/usr/local/etc/fluentd"
  fluentd_config_dir   = "/usr/local/etc/fluentd/conf.d"
  fluentd_gem_bin = "/usr/local/bin/fluent-gem"
  fluentd_certs_dir    = "/usr/local/etc/fluentd/certs"
  default_group        = "wheel"
  pid_dir_mode         = 775
  fluentd_log_dir      = "/var/log/fluentd"
  fluentd_log_file     = "#{fluentd_log_dir}/fluentd.log"
when "openbsd"
  fluentd_user_name     = "_fluentd"
  fluentd_user_group    = "_fluentd"
  fluentd_package_name  = "fluentd"
  fluentd_service_name  = "fluentd"
  fluentd_config_path   = "/etc/fluentd/fluent.conf"
  fluentd_conf_dir      = "/etc/fluentd"
  fluentd_config_dir    = "/etc/fluentd/conf.d"
  fluentd_gem_bin       = "/usr/local/bin/fluent-gem"
  fluentd_certs_dir     = "#{fluentd_conf_dir}/certs"
  default_group         = "wheel"
  fluentd_log_dir      = "/var/log/fluentd"
  fluentd_log_file     = "#{fluentd_log_dir}/fluentd.log"
end
fluentd_plugin_dir = "#{fluentd_conf_dir}/plugin"
pid_dir = "/var/run/#{fluentd_service_name}"
pid_file = "#{pid_dir}/#{fluentd_service_name}.pid"

if os[:family] == "openbsd"
  describe package(fluentd_package_name) do
    it do
      pending "regex in serverspec does not match"
      # $ sudo -p 'Password: ' /bin/sh -c gem\ list\ --local\ \|\ grep\ -iw\ --\ \\\^fluentd\\\
      # $ echo $?
      # 1
      #
      # if `-w` flag is removed, it does
      #
      # $ sudo -p 'Password: ' /bin/sh -c gem\ list\ --local\ \|\ grep\ -i\ --\ \\\^fluentd\\\
      # fluentd (0.14.16)
      should be_installed.by("gem")
    end
  end
  describe command("gem list --local") do
    its(:stdout) { should match(/^fluentd /) }
    its(:exit_status) { should eq(0) }
    its(:stderr) { should eq("") }
  end
else
  describe package(fluentd_package_name) do
    it { should be_installed }
  end
end

describe user(fluentd_user_name) do
  extra_groups.each do |g|
    it { should belong_to_group g }
  end
end

describe file(fluentd_config_dir) do
  it { should be_directory }
  it { should be_mode 755 }
end

describe file(fluentd_plugin_dir) do
  it { should exist }
  it { should be_directory }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
  it { should be_mode 755 }
end

describe file("#{fluentd_plugin_dir}/example.rb") do
  it { should exist }
  it { should be_mode 644 }
  it { should be_file }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
  its(:content) { should match(/^\s+#{Regexp.escape('Fluent::Plugin.register_input("example", self)')}$/) }
end

describe file(fluentd_log_dir) do
  it { should be_directory }
  it { should be_mode 755 }
  it { should be_owned_by fluentd_user_name }
  it { should be_grouped_into fluentd_user_group }
end

case os[:family]
when "openbsd"
  describe file("/etc/rc.conf.local") do
    it { should be_file }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    it { should be_mode 644 }
    its(:content) { should match(/^#{Regexp.escape("fluentd_flags=--daemon #{pid_file} --config #{fluentd_config_path} -p #{fluentd_plugin_dir} --log #{fluentd_log_file}")}/) }
  end
  fluentd_binary = %w(
    fluent-binlog-reader
    fluent-cat
    fluent-debug
    fluent-gem
    fluent-plugin-config-format
    fluent-plugin-generate
    fluentd
  )
  fluentd_binary.each do |bin|
    describe file("/usr/local/bin/#{bin}") do
      it { should be_symlink }
      it { should be_linked_to "/usr/local/bin/#{bin}23" }
    end

    describe file("/usr/local/bin/#{bin}23") do
      it { should be_file }
      it { should be_mode 755 }
      it { should be_owned_by default_user }
      it { should be_grouped_into default_group }
    end

    describe command("/usr/local/bin/#{bin}23 --help") do
      # intentionally ignore stdout here becase there is no common output. what
      # is being tested here is; the binary can be compiled and runnable
      its(:exit_status) { should eq bin == "fluent-binlog-reader" ? 1 : 0 }
      its(:stderr) { should eq "" }
    end
  end
when "redhat"
  describe file("/etc/sysconfig/td-agent") do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    its(:content) { should match(/^TD_AGENT_OPTIONS=" --log #{Regexp.escape(fluentd_log_file)}"$/) }
  end
when "ubuntu"
  describe file("/etc/default/td-agent") do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    its(:content) { should match(/^TD_AGENT_OPTIONS="-p #{Regexp.escape(fluentd_plugin_dir)} --log #{Regexp.escape(fluentd_log_file)}"$/) }
  end
when "freebsd"
  describe file("/etc/rc.conf.d") do
    it { should be_directory }
    it { should be_mode 755 }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
  end

  describe file("/etc/rc.conf.d/fluentd") do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    its(:content) { should match(%r{^fluentd_flags="-p #{Regexp.escape(fluentd_plugin_dir)} --log #{Regexp.escape(fluentd_log_file)}"$}) }
  end
end

describe file(fluentd_config_path) do
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
  its(:content) { should match(/log_level debug/) }
  its(:content) { should match(/suppress_config_dump/) }
  its(:content) { should match(/^@include\s+#{ Regexp.escape(fluentd_config_dir + "/*.conf") }$/) }
end

describe file(pid_dir) do
  it { should be_directory }
  it { should be_owned_by fluentd_user_name }
  it { should be_grouped_into fluentd_user_group }
  it { should be_mode pid_dir_mode }
end

describe file(pid_file) do
  it { should be_file }
  it { should be_owned_by fluentd_user_name }
  it { should be_grouped_into fluentd_user_group }
  it { should be_mode 644 }
  its(:content) { should match(/^\d+$/) }
end

describe service(fluentd_service_name) do
  it { should be_running }
  it { should be_enabled }
end

describe command("#{fluentd_gem_bin} list") do
  its(:stdout) { should match(/fluent-plugin-redis/) }
  its(:stdout) { should match(/fluent-plugin-secure-forward/) }
end

describe file("#{fluentd_config_dir}/listen_on_5140.conf") do
  its(:content) { should match(/@type syslog/) }
  its(:content) { should match(/port 5140/) }
end

describe port(5140) do
  it do
    pending "fails because regex is wrong" if os[:family] == "openbsd"
    # udp          0      0  127.0.0.1.5140         *.*
    should be_listening
  end
end

if os[:family] == "openbsd"
  describe command("netstat -anf inet") do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/udp\s+\d+\s+\d+\s+#{Regexp.escape("127.0.0.1")}\.5140\s+\*\.\*/) }
  end
end

describe file(fluentd_certs_dir) do
  it { should be_directory }
  it { should be_mode 755 }
end

describe file("#{fluentd_certs_dir}/ca_key.pem") do
  it { should be_file }
  its(:content) { should match Regexp.escape("Proc-Type: 4,ENCRYPTED") }
  it { should be_mode 440 }
  it { should be_owned_by fluentd_user_name }
  it { should be_grouped_into fluentd_user_group }
end

describe file("#{fluentd_certs_dir}/ca_cert.pem") do
  it { should be_file }
  its(:content) { should match(/MIIDIDCCAggCAQEwDQYJKoZIhvcNAQEFBQAwTTELMAkGA1UEBhMCVVMxCzAJBgNV/) }
  it { should be_mode 644 }
  it { should be_owned_by fluentd_user_name }
  it { should be_grouped_into fluentd_user_group }
end

describe file(fluentd_buffer_dir) do
  it { should be_directory }
  it { should be_owned_by fluentd_user_name }
  it { should be_grouped_into fluentd_user_group }
  it { should be_mode 755 }
end

describe file(fluentd_unix_pipe_dir) do
  it { should be_directory }
  it { should be_owned_by fluentd_user_name }
  it { should be_grouped_into fluentd_user_group }
  it { should be_mode 755 }
end

describe file("#{fluentd_unix_pipe_dir}/fluentd.sock") do
  it { should be_pipe }
  it { should be_owned_by fluentd_user_name }
  it { should be_grouped_into fluentd_user_group }
  it { should be_mode 660 }
end

describe file(fluentd_log_file) do
  it { should be_file }
  it { should be_owned_by fluentd_user_name }
  it { should be_grouped_into fluentd_user_group }
  it { should be_mode 644 }
  # XXX make sure the `reload` issue has been fixed
  # https://github.com/reallyenglish/ansible-role-fluentd/issues/44
  its(:content) { should match(/fluentd supervisor process get SIGHUP/) }
end
