describe command('sudo uname -r') do
  its('stdout') { should include '4.18.0-240.1.1.el8_3.x86_64' }
end

describe systemd_service('openvswitch') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe command('sudo ovs-vsctl show') do
  its('stdout') { should include '2.13.2' }
end

describe systemd_service('docker') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end

describe command('sudo docker --version') do
  its('stdout') { should include '20.10.3' }
end

describe command('ovs-docker') do
  it { should exist }
end