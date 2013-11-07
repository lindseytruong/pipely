require 'pipely/definition'
require 'pipely/graph_builder'
require 'pipely/live_pipeline'

# The top-level module for this gem. It provides the recommended public
# interface for using Pipely to visualize and manipulate your Data Pipeline
# definitions.
#
module Pipely

  def self.draw(definition_json, filename, component_attributes=nil)
    definition = Definition.parse(definition_json)

    if component_attributes
      definition.apply_component_attributes(component_attributes)
    end

    graph_builder = GraphBuilder.new

    graph = graph_builder.build(definition.components_for_graph)
    graph.output( :png => filename )
  end

end
