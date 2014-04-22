require 'pp'
require 'pipely/aws/data_pipeline/pipeline'

module Pipely
  module Actions

    # List currently deployed pipelines
    #
    class ListLogPaths

      def initialize(options)
        @options = options
      end

      def execute
        if @options.object_id
          $stdout.puts PP.pp(log_paths_for_component, "")
        else
          $stdout.puts PP.pp(log_paths, "")
        end
      end

    private

      def log_paths_for_component
        data_pipeline.log_paths_for_component(@options.object_id)
      end

      def log_paths
        data_pipeline.log_paths
      end

      def data_pipeline
        Pipely::DataPipeline::Pipeline.new(@options.pipeline_id)
      end

    end

  end
end