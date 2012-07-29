require 'fileutils'
require 'tmpdir'

class Deployer

  def self.deploy_to_bucket_from_commit( *args )
    new.deploy_to_bucket_from_commit( *args )
  end
  
  def deploy_to_bucket_from_commit( bucket_name, commit_sha )
    using_a_temporary_dir do |temp_dir|
      extract_commit_into_dir( commit_sha, temp_dir )
      prep_gems_in_dir( temp_dir )
      Dir.chdir temp_dir do
        generate_site
        deploy_site_to_bucket( bucket_name )
      end
    end
  end

  private

  def using_a_temporary_dir &block
    Dir.mktmpdir("octopress_deployment",&block)
    #temp_dir = Dir.mktmpdir
    #puts "temp dir is #{temp_dir}"
    #yield temp_dir
  end

  def extract_commit_into_dir( commit_sha, dir )
    `git archive --format=tar #{commit_sha} | tar -x -C #{dir}`
    raise 'git archive failed' unless $?.success?
  end

  def prep_gems_in_dir( dir )
    FileUtils.cp_r( '.bundle', dir )
    FileUtils.cp_r( 'vendor', dir )
  end

  def generate_site
    success = system 'bundle exec rake generate'
    raise 'rake generate failed' unless success
  end

  def deploy_site_to_bucket( bucket_name )
    success = system "s3cmd sync --acl-public --no-delete-removed --reduced-redundancy public/* s3://#{bucket_name}/"
    raise 'deploy failed' unless success
  end

end
