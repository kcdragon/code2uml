require_relative '../../lib/exploration/class_entity'
require_relative '../../lib/exploration/method_entity'
require_relative '../../lib/exploration/dependency_relation'
require_relative '../../lib/sexp_factory'
require_relative 'sexp_helper'

describe Exploration::ClassEntity do
  include SexpHelper

  let(:class_entity) do
    class_entity = Exploration::ClassEntity.new
    method_explorer = Exploration::MethodEntity.new
    method_explorer.add_explorer Exploration::DependencyRelation.new
    class_entity.add_explorer method_explorer
    class_entity
  end
  subject { class_entity }

  let(:foo) {  { name: 'Foo', type: :class, namespace: [] } }
  let(:say_hello) { { name: 'say_hello', type: :method } }
  
  
  it "has a dependency" do
    program = "class Foo; def say_hello; puts Hello.hi; end; end"
    expect do |b|
      subject.each(get_sexp(program), nil, &b)
    end.to yield_successive_args(
                                 foo,
                                 [foo, :defines, say_hello],
                                 [foo, :dependency, { name: 'Hello', type: :class, namespace: [] }])
  end

  it "does not have a dependency" do
    program = "class Foo; def say_hello; puts 'hello'; end; end"
    expect { |b| subject.each(get_sexp(program), nil, &b) }.to yield_successive_args(foo, [foo, :defines, say_hello])
  end

  it "does not explore classes nested inside module" do
    program = "module Bar; class Foo; end; end"
    expect { |b| subject.each(get_sexp(program), nil, &b) }.to_not yield_control
  end
end
