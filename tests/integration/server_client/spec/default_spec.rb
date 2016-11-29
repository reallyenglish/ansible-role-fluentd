require "spec_helper"

class ServiceNotReady < StandardError
end

sleep 10 if ENV['JENKINS_HOME']

digest = Digest::SHA256.hexdigest(Time.new.to_i.to_s)
context 'after provisioning finished' do
  describe server(:client) do
    it "runs logger" do
      result = current_server.ssh_exec("logger %s && echo OK" % [ Shellwords.escape(digest) ])
      expect(result).to match(/OK/)
    end
  end
end

context "after client sends message" do
  describe server(:server) do
    it "receives the message via syslog" do
      result = current_server.ssh_exec("grep #{digest} /tmp/fluentd.log")
      expect(result).to match(/#{ digest }/)
    end
  end
end
