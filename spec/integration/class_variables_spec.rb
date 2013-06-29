require_relative '../../lib/graph/edge'
require_relative '../../lib/graph/vertex'
require_relative 'graph_generator_helper'

describe "Class Variables" do
  include GraphGeneratorHelper

  let(:foo) { Graph::Vertex.new('Foo', :class) }
  let(:bar) { Graph::Vertex.new('Bar', :class) }

  it "generates single class with one to one class variable" do
    graph = generate_graph "class Foo; def self.hello; @@bar = Bar.new; end; end"
    foo.add_edge Graph::Edge.new(:aggregation), bar
    foo.add_edge Graph::Edge.new(:dependency), bar # TODO aggregation is also a dependency, might want to fix this by only making this aggregation
    expect(graph.each.to_a).to match_array [foo, bar]
  end
end