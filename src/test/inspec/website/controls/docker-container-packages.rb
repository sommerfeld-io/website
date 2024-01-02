# @file docker-container-packages.rb
# @brief Verify the pacakge installations inside the Docker container.
#
# @description This Inspec Module verifies the pacakge installations inside the Docker container.
#
# This module adopts tests from https://dev-sec.io/baselines/linux.

title "Verify packages inside Docker container"

container_execution = begin
    virtualization.role == 'guest' && virtualization.system =~ /^(lxc|docker)$/
    rescue NoMethodError
        false
end

control 'package-01' do
    impact 1.0
    title 'Do not run deprecated inetd or xinetd'
    desc 'http://www.nsa.gov/ia/_files/os/redhat/rhel5-guide-i731.pdf, Chapter 3.2.1'

    describe package('inetd') do
        it { should_not be_installed }
    end

    describe package('xinetd') do
        it { should_not be_installed }
    end
end

control 'package-02' do
    impact 1.0
    title 'Do not install Telnet server'
    desc 'Telnet protocol uses unencrypted communication, that means the password and other sensitive data are unencrypted. http://www.nsa.gov/ia/_files/os/redhat/rhel5-guide-i731.pdf, Chapter 3.2.2'

    describe package('telnetd') do
        it { should_not be_installed }
    end
end

control 'package-03' do
    impact 1.0
    title 'Do not install rsh server'
    desc 'The r-commands suffers same problem as telnet. http://www.nsa.gov/ia/_files/os/redhat/rhel5-guide-i731.pdf, Chapter 3.2.3'

    describe package('rsh-server') do
        it { should_not be_installed }
    end
end

control 'package-05' do
    impact 1.0
    title 'Do not install ypserv server (NIS)'
    desc 'Network Information Service (NIS) has some security design weaknesses like inadequate protection of important authentication information. http://www.nsa.gov/ia/_files/os/redhat/rhel5-guide-i731.pdf, Chapter 3.2.4'

    describe package('ypserv') do
        it { should_not be_installed }
    end
end

control 'package-06' do
    impact 1.0
    title 'Do not install tftp server'
    desc 'tftp-server provides little security http://www.nsa.gov/ia/_files/os/redhat/rhel5-guide-i731.pdf, Chapter 3.2.5'

    describe package('tftp-server') do
        it { should_not be_installed }
    end
end

control 'package-09' do
    impact 1.0
    title 'CIS: Additional process hardening'
    desc '1.5.4 Ensure prelink is disabled'

    describe package('prelink') do
        it { should_not be_installed }
    end
end

control "node-npm-yarn" do
    impact 1.0
    title "No Node, NPM or Yarn binaries, node_modules or configs"
    desc "No Node, NPM or Yarn binaries, node_modules or configs (from intermediate stages) should be present in the final image"

    FORBIDDEN_CONFIGS = %w(
        /usr/local/share/.config/yarn/global
        /usr/local/share/.config/yarn/global/node_modules
        /usr/local/share/.config/yarn/global/node_modules/@antora
        /usr/local/share/.config/yarn/global/node_modules/@asciidoctor
        /usr/local/share/.config/yarn/global/node_modules/asciidoctor-kroki
    )
    FORBIDDEN_CONFIGS.each do |config|
        describe file(config) do
            it { should_not exist }
        end
    end

    describe package('node') do
        it { should_not be_installed }
    end

    describe package('npm') do
        it { should_not be_installed }
    end

    describe package('yarn') do
        it { should_not be_installed }
    end

    describe package('antora') do
        it { should_not be_installed }
    end

    describe package('gulp') do
        it { should_not be_installed }
    end
end
