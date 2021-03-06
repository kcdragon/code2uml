require_relative 'exploration/resolve/simple_resolve_strategy'

require_relative 'graph/digraph'
require_relative 'graph/edge'
require_relative 'graph/namespace'
require_relative 'graph/vertex'

class GraphGenerator
  attr_reader :graph
  attr_writer :resolve_strategy

  def initialize
    @graph = Digraph.new
    @resolve_strategy = SimpleResolveStrategy.new
  end

  # Traverse +sexp+ using the given +explorer+ and store the extracted relationships in the +graph+.
  #
  # [params] - explorer is an Explorable used for the traversal
  #          - sexp is a Sexp that is the subject of the traversal
  def process_sexp explorer, sexp
    explorer.each(sexp) do |entity, relation, other_entity|
      vertex = get_or_create_vertex @graph, entity[:name], entity[:namespace], entity[:type]
      if not relation.nil?
        o_vertex = get_or_create_vertex @graph, other_entity[:name], other_entity[:namespace], other_entity[:type]
        edge = get_edge relation
        vertex.add_edge edge, o_vertex
      end
    end
  end
  
private

  def get_or_create_vertex graph, name, namespace, type
    vertex = nil
    if graph.has_vertex? name
      vertices = graph.find_vertex(name)
      found_vertex = vertices.first
      new_vertex = create_vertex(name, namespace, type)
      if @resolve_strategy.is_same?(found_vertex, new_vertex)
        vertex = @resolve_strategy.merge_vertices(found_vertex, new_vertex)
        @resolve_strategy.rereference_incoming_edges!(vertex, found_vertex, new_vertex)
        graph.remove_vertex found_vertex
        graph.remove_vertex new_vertex
      else
        vertex = new_vertex
      end
    else
      vertex = create_vertex(name, namespace, type)
    end
    graph.add_vertex vertex
    return vertex
  end

  def create_vertex name, namespace, type
    Vertex.new name, type, namespace
  end

  def get_edge type
    Edge.new type
  end
end
