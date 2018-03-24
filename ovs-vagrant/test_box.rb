describe command('sudo uname -r') do
  its('stdout') { should include '3.10.0-693.17.1.el7.x86_64' }
end

describe systemd_service('openvswitch') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe command('sudo ovs-vsctl show') do
  its('stdout') { should include '2.7.3' }
end

describe systemd_service('docker') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end

describe command('sudo docker --version') do
  its('stdout') { should include '17.05.0-ce' }
end

describe command('ovs-docker') do
  it { should exist }
end