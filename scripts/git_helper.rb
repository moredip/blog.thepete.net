module GitHelper
  class << self
    def distance_between_revs( old_rev, new_rev )
      output = `git rev-list #{old_rev}..#{new_rev}`
      unless $?.success?
        puts output
        raise "couldn't figure out the relationship between the preprod marker branch and the rev you want to deploy"
      end

      output.split("\n").count
    end

    def is_fast_forward( old_rev, new_rev )
      distance_between_revs( new_rev, old_rev ) == 0
    end
  end
end
