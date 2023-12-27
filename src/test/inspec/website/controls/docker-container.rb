# @file docker-container.rb
# @brief Verify if the operating system type and configuration
#
# @description This Inspec Module verifies if the operating system type and configuration.
# The basic Docker container setup is checked as well.
# TODO ...
#
# == See also
#
# * https://docs.chef.io/inspec/resources/os
# * https://docs.chef.io/inspec/resources/user

title "Verify Docker container"

control "docker-container-os" do
    impact 0.5
    title "Verify operating system"
    desc "Verify if the operating system type and configuration"

    describe os.family do
        it { should eq 'linux' }
    end
end

control "docker-container-config" do
    impact 0.8
    title "Container Configuration Validation"
    desc "Verify the configuration settings within the Docker container"

    describe user('root') do
        it { should exist }
        it { should have_home_directory '/root' }
        it { should have_login_shell '/bin/ash' }
    end

    describe user('www-data') do
        it { should exist }
        it { should have_home_directory '/home/www-data' }
        it { should have_login_shell '/sbin/nologin' }
    end

#     describe docker_container('website') do
#         it { should exist }
#         it { should be_running }
#         its('image') { should eq 'httpd:2.4.58-alpine3.18' }
#         its('repo') { should eq 'httpd' }
#         its('tag') { should eq '2.4.58-alpine3.18' }
#         its('ports') { should eq '0.0.0.0:7888->7888/tcp' }
#     end
end
