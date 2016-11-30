require "spec_helper"

class ServiceNotReady < StandardError
end

sleep 10 if ENV['JENKINS_HOME']

digest1 = Digest::SHA256.hexdigest(Time.new.to_f.to_s)
sleep 1
digest2 = Digest::SHA256.hexdigest(Time.new.to_f.to_s)
context 'after provisioning finished' do
  describe server(:client) do
    it "sends digest1 via logger" do
      result = current_server.ssh_exec("logger %s && echo OK" % [ Shellwords.escape(digest1) ])
      expect(result).to match(/OK/)
    end
    it "sends digest2 via unix socket" do
      message = { :key => digest2 }.to_json
      result = current_server.ssh_exec("echo #{ Shellwords.escape(message) } | fluent-cat info.test -u -s /var/tmp/fluentd/fluentd.sock && echo OK")
      expect(result).to match(/OK/)
    end
  end
end

context "after client sends message" do
  describe server(:server) do
    it "receives digest1" do
      sleep 10
      result = current_server.ssh_exec("grep #{digest1} /tmp/fluentd.log.*")
      expect(result).to match(/#{ digest1 }/)
    end

    it "receives digest2" do
      sleep 30
      result = current_server.ssh_exec("grep #{digest2} /tmp/fluentd.log.*")
      expect(result).to match(/#{ digest2 }/)
    end
  end
end
