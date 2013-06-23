require_relative 'explorable'

module Exploration
  class Relation < Explorable

    # types_to_search: Hash of types => callback
    def each_of_type type, sexp, context, types_to_search, &block
      sexp.each_child do |sub_sexp|
        if sub_sexp.first == type
          method_node = sub_sexp
          method_body = method_node.rest.rest.rest
          method_body.deep_each do |sub_sexp|
            types_to_search.each do |type, callback|
              if type.include? sub_sexp.first
                callback.call(sub_sexp)
              end
            end
          end
        end
      end
    end
  end
end
