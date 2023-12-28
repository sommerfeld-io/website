# @file filesystem.rb
# @brief Verify files and folders
#
# @description This Inspec Module verifies files and folders containing the webserver
# configuration and the website content. That includes that no artifacts from intermediate
# stages should be present in the final image (other than the website itself).
#
# The following checks are part of this test file:
#
# * Check existence of mandatory files and folders
# * No files of folders from intermediate stages

title "Verify files and folders"

control "website-and-webserver" do
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

control "antora-build" do
    impact 1.0
    title "No files of folders from intermediate stages"
    desc "No files of folders from intermediate stages should be present in the final image (other than the website itself)"

    FORBIDDEN_ARTIFACT = %w(
        /antora
        /antora/playbooks/docs.yml
        /antora/playbooks/personal-projects.yml
        /antora-src
        /antora-src/main/ui/material-admin-pro/ui-bundle.zip
    )
    FORBIDDEN_ARTIFACT.each do |artifact|
        describe file(artifact) do
            it { should_not exist }
        end
    end
end
