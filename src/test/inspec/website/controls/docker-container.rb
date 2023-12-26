# @file docker-container.rb
# @brief Verify if the operating system type and configuration
#
# @description This Inspec Module verifies if the operating system type and configuration.
# The basic Docker container setup is checked as well.
# TODO ...
#
# == See also
#
# * link:https://docs.chef.io/inspec/resources/os/#osfamily-helpers[os resource]

title "Verify Docker container"

control "os" do
    impact 0.5
    title "Verify operating system"
    desc "Verify if the operating system type and configuration"

    describe os.family do
        it { should eq 'linux' }
    end
end

# control "image-config" do
#     impact 0.8
#     title "A human-readable title ... ... ... ... ... ... ... ... ... ... ... ... ... ... ..."
#     desc "An optional description ... ... ... ... ... ... ... ... ... ... ... ... ... ... ..."

#     describe docker_container('website') do
#         it { should exist }
#         it { should be_running }
#         its('image') { should eq 'httpd:2.4.58-alpine3.18' }
#         its('repo') { should eq 'httpd' }
#         its('tag') { should eq '2.4.58-alpine3.18' }
#         its('ports') { should eq '0.0.0.0:7888->7888/tcp' }
#     end
# end
