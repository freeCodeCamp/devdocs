require 'test_helper'
require 'docs'

class DocsInstrumentableTest < MiniTest::Spec
  let :extended_class do
    Class.new.tap { |klass| klass.send :extend, Docs::Instrumentable }
  end

  let :included_class do
    Class.new.tap { |klass| klass.send :include, Docs::Instrumentable }
  end

  it "works when extended" do
    extended_class.subscribe('test') { @called = true }
    extended_class.instrument 'test'
    assert @called
  end

  it "works when included" do
    instance = included_class.new
    instance.subscribe('test') { @called = true }
    instance.instrument 'test'
    assert @called
  end
end
