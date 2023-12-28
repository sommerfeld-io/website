# @file docker-multistage.rb
# @brief Verify the Docker multistage build.
#
# @description This Inspec Module verifies that no artifacts from intermediate stages
# should be present in the final image (other than the website itself).
# TODO ...

title "Verify Docker multistage build"

control "docker-multistage" do
    impact 1.0
    title "No artifacts from intermediate stages"
    desc "No artifacts from intermediate stages should be present in the final image (other than the website itself)"

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

    # TODO move to docker-packages.rb
    # FORBIDDEN_NODE_PACKAGE = %w(
    #     @asciidoctor/core
    #     asciidoctor-kroki
    #     @antora/lunr-extension
    # )
    # FORBIDDEN_NODE_PACKAGE.each do |package|
    #     describe npm(package) do
    #         it { should_not exist }
    #     end
    # end
end
