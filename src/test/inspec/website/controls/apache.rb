# @file apache.rb
# @brief Verify Apache httpd configuration inside the ``sommerfeldio/website:rc`` Docker image.
#
# @description This Inspec module verifies Apache httpd configuration inside
# the ``sommerfeldio/website:rc`` Docker image.
#
# This module adopts tests from https://dev-sec.io/baselines/apache.
#
# The following checks are part of this test file:
#
# * Check Apache config folder owner, group and permissions
# * Check Apache config file owner, group and permissions
# * User and group should be set properly
# * Should not load certain modules
# * Disable insecure HTTP-methods
# * Disable Apache's follows Symbolic Links for directories in httpd.conf
# * Disable Directory Listing for directories in httpd.conf
# * Check HTTP code handling
# * ExtendedStatus should be on
# * Rewrite Engine should be on

title 'Apache server config'

only_if do
    command(apache.service).exist? || file(apache.conf_dir).exist? || service(apache.service).installed?
end

title 'Apache server config'

control 'apache-04' do
    impact 1.0
    title 'Check Apache config folder owner, group and permissions'
    desc 'The Apache config folder should owned and grouped by www-data, be writable, readable and executable by owner. It should be readable by group and others, executable by group, not writeable by others.'

    describe file(apache.conf_dir) do
        it { should be_owned_by apache.user }
        it { should be_grouped_into apache.user }
        it { should be_readable.by('owner') }
        it { should be_writable.by('owner') }
        it { should be_executable.by('owner') }
        it { should be_readable.by('group') }
        it { should_not be_writable.by('group') }
        it { should be_executable.by('group') }
        it { should be_readable.by('others') }
        it { should_not be_writable.by('others') }
        it { should be_executable.by('others') }
    end
end

control 'apache-05' do
    impact 1.0
    title 'Check Apache config file owner, group and permissions'
    desc 'The Apache config file should owned and grouped by root, readable by everyone, only be writable by owner and not writeable by group or others.'

    describe file(apache.conf_path) do
        it { should be_owned_by apache.user }
        it { should be_grouped_into apache.user }
        it { should be_readable.by('owner') }
        it { should be_writable.by('owner') }
        it { should_not be_executable.by('owner') }
        it { should be_readable.by('group') }
        it { should_not be_writable.by('group') }
        it { should_not be_executable.by('group') }
        it { should be_readable.by('others') }
        it { should_not be_writable.by('others') }
        it { should_not be_executable.by('others') }
    end
end

control 'apache-06' do
    impact 1.0
    title 'User and group should be set properly'
    desc 'For security reasons it is recommended to run Apache in its own non-privileged account.'

    describe apache_conf(apache.conf_path) do
        its('Listen') { should cmp '7888' }
        its('User') { should eq [apache.user] }
        its('Group') { should eq [apache.user] }
    end
end

control 'apache-08' do
    impact 1.0
    title 'Should not load certain modules'
    desc 'Apache HTTP should not load legacy modules'

    describe file(apache.conf_path) do
        its('content') { should_not match(/^\s*?LoadModule\s+?dav_module/) }
        its('content') { should_not match(/^\s*?LoadModule\s+?cgid_module/) }
        its('content') { should_not match(/^\s*?LoadModule\s+?cgi_module/) }
        its('content') { should_not match(/^\s*?LoadModule\s+?include_module/) }
    end

    # open bug https://github.com/chef/inspec/issues/786, if the bug solved use this test
    # describe apache_conf(apache.conf_path) do
    #     its('LoadModule') { should_not eq 'dav_module' }
    #     its('LoadModule') { should_not eq 'cgid_module' }
    #     its('LoadModule') { should_not eq 'cgi_module' }
    #     its('LoadModule') { should_not eq 'include_module' }
    #     its('content') { should_not match(/^\s*?LoadModule\s+?dav_module/) }
    #     its('content') { should_not match(/^\s*?LoadModule\s+?cgid_module/) }
    #     its('content') { should_not match(/^\s*?LoadModule\s+?cgi_module/) }
    #     its('content') { should_not match(/^\s*?LoadModule\s+?include_module/) }
    # end
end

control 'apache-10' do
    impact 1.0
    title 'Disable insecure HTTP-methods'
    desc 'Disable insecure HTTP-methods and allow only necessary methods.'

    describe file(apache.conf_path) do
        its('content') { should match(/^\s*?<LimitExcept\s+?GET\s+?POST>/) }
    end

    # open bug https://github.com/chef/inspec/issues/786, if the bug solved use this test
    # describe apache_conf(apache.conf_path) do
    #     its('LimitExcept') { should eq ['GET','POST'] }
    # end
end

control 'apache-11' do
    impact 1.0
    title 'Disable Apache\'s follows Symbolic Links for directories in httpd.conf'
    desc 'Should include -FollowSymLinks or +SymLinksIfOwnerMatch for directories in httpd.conf'

    describe file(apache.conf_path) do
        its('content') { should match(/-FollowSymLinks/).or match(/\+SymLinksIfOwnerMatch/) }
    end
end

control 'apache-12' do
    impact 1.0
    title 'Disable Directory Listing for directories in httpd.conf'
    desc 'Should include -Indexes for directories in httpd.conf'

    describe file(apache.conf_path) do
        its('content') { should match(/-Indexes/) }
    end
end

control 'apache-error-document' do
    impact 1.0
    title 'HTTP codes'
    desc 'Check HTTP code handling'

    describe file(apache.conf_path) do
        its('content') { should match(/^\s*?ErrorDocument\s+?403/) }
    end

    describe file(apache.conf_path) do
        its('content') { should match(/^\s*?ErrorDocument\s+?404/) }
    end

    describe file(apache.conf_path) do
        its('content') { should match(/^\s*?ErrorDocument\s+?500/) }
    end

    describe file(apache.conf_path) do
        its('content') { should match(/^\s*?ErrorDocument\s+?503/) }
    end

    describe file(apache.conf_path) do
        its('content') { should match(/^\s*?ErrorDocument\s+?504/) }
    end
end

control 'apache-server-status' do
    impact 1.0
    title 'ExtendedStatus should be on'
    desc 'ExtendedStatus is needed to expose apache information through /server-status'

    describe file(apache.conf_path) do
        its('content') { should match(/^\s*?ExtendedStatus\s+?On/) }
    end

    # open bug https://github.com/chef/inspec/issues/786, if the bug solved use this test
    # describe apache_conf(apache.conf_path) do
    #     its('ExtendedStatus') { should eq 'On' }
    # end

    describe file(apache.conf_path) do
        its('content') { should match(/^\s*?SetHandler\s+?server-status/) }
    end
end

control 'apache-rewrite' do
    impact 1.0
    title 'Rewrite Engine should be on'
    desc 'Website uses rewrite rules to steer certain requests to the desired target'

    describe file(apache.conf_path) do
        its('content') { should match(/^\s*?RewriteEngine\s+?On/) }
    end

    # open bug https://github.com/chef/inspec/issues/786, if the bug solved use this test
    # describe apache_conf(apache.conf_path) do
    #     its('RewriteEngine') { should eq 'On' }
    # end
end
