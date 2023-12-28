# @file apache.rb
# @brief Library module which provides some helper functions for the ``apache.rb`` Inspec test.
#
# @description This Inspec Library module provides some helper functions for
# the ``apache.rb`` Inspec test.

class Apache < Inspec.resource(1)
  name 'apache'
  supports platform: 'unix'
  desc 'Use the apache InSpec audit resource to retrieve Apache environment settings.'
  example <<~EXAMPLE
    describe apache do
      its ('service') { should cmp 'apache2' }
    end

    describe apache do
      its ('conf_dir') { should cmp '/etc/apache2' }
    end

    describe apache do
      its ('conf_path') { should cmp '/etc/apache2/apache2.conf' }
    end

    describe apache do
      its ('user') { should cmp 'www-data' }
    end
  EXAMPLE

  attr_reader :service, :conf_dir, :conf_path, :user

  def initialize
    super

    @service = 'httpd'
    @conf_dir = '/usr/local/apache2'
    @conf_path = File.join @conf_dir, '/conf/httpd.conf'
    @user = 'www-data'
  end

  def to_s
    'Apache Environment'
  end
end
