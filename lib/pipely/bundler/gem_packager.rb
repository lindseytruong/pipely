require 'fileutils'
require 'excon'

module Pipely
  module Bundler

    #
    # Builds cache files for git- or path-sourced gems.
    #
    class GemPackager

      #
      # Alert upon gem-building failures
      #
      class GemBuildError < RuntimeError ; end

      def initialize(dest)
        if Dir.exists? dest
          @dest = dest
        else
          raise "#{dest} does not exist"
        end
      end

      def package(spec)
        gem_file = spec.cache_file
        vendored_gem = File.join( @dest, File.basename(gem_file) )

        # Gem has already been vendored
        return { spec.name => vendored_gem } if File.exists?(vendored_gem)

        # Gem exists in the local ruby gems cache
        if File.exists? gem_file

          # Copy to vendor dir
          FileUtils.cp(gem_file, vendored_gem)

          { spec.name => vendored_gem }

        # If source exists, build a gem from it
        elsif File.directory?(spec.gem_dir)
          build_from_source(spec.name, spec.gem_dir)

        else
          # Finally, some gems do not exist in the cache or as source.  For
          # instance, json is shipped with the ruby dist.  Skip these.
          {}
        end
      end

      def build_from_source(spec_name, source_path)
        gem_spec_path = "#{spec_name}.gemspec"

        # Build the gemspec
        gem_spec = Gem::Specification::load(
          File.join(source_path,gem_spec_path))

        gem_file = nil

        # build the gem
        Dir.chdir(source_path) do
          result = `gem build #{gem_spec_path} 2>&1`

          if result =~ /ERROR/i
            raise GemBuildError.new(
              "Failed to build #{gem_spec_path} \n" << result)
          else
            gem_file = result.scan(
                /File:(.+.gem)$/).flatten.first.strip
          end

          # Move to vendor dir
          FileUtils.mv(
            File.join(source_path,gem_file),
            File.join(@dest,gem_file))
        end

        { gem_spec.name => File.join(@dest, gem_file) }
      end
    end
  end
end
