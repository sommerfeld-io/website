# @file filesystem.rb
# @brief Verify files and folders
#
# @description This Inspec Module verifies files and folders containing the webserver
# configuration and the website content.
# TODO ...

title "Verify files and folders"

control "files-and-folders" do
    impact 0.7
    title "Check existence of mandatory files and folders"
    desc "Check files and folders containing the webserver configuration and the website content"

    FOLDERS = %w(
        /usr/local/apache2/htdocs/docs
        /usr/local/apache2/htdocs/docs-personal-projects
    )
    FOLDERS.each do |folder|
        describe file(folder) do
            it { should exist }
            it { should_not be_file }
            it { should be_directory }
        end
    end

    FILES = %w(
        /usr/local/apache2/conf/httpd.conf
        /usr/local/apache2/htdocs/robots.txt
        /usr/local/apache2/htdocs/terms-conditions.html
        /usr/local/apache2/htdocs/contact.html

        /usr/local/apache2/htdocs/docs/search-index.js
        /usr/local/apache2/htdocs/docs-personal-projects/search-index.js
    )
    FILES.each do |file|
        describe file(file) do
            it { should exist }
            it { should be_file }
            it { should_not be_directory }
        end
    end

end
