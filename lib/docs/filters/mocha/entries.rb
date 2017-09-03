module Docs
  class Mocha
    class EntriesFilter < Docs::EntriesFilter
      ENTRIES = {
        'asynchronous-code' => ['done()'],
        'hooks' => ['before()', 'after()', 'beforeEach()', 'afterEach()', 'suiteSetup()', 'suiteTeardown()', 'setup()', 'teardown()'],
        'exclusive-tests' => ['only()'],
        'inclusive-tests' => ['skip()'],
        'bdd' => ['describe()', 'context()', 'it()', 'specify()'],
        'tdd' => ['suite()', 'test()'],
        'exports' => ['exports'],
        'qunit' => ['QUnit'],
        'require' => ['require'],
        'browser-specific-methods' => ['mocha.allowUncaught()', 'mocha.setup()', 'mocha.run()', 'mocha.globals()', 'mocha.checkLeaks()'],
        'timeouts' => ['timeout()']
      }

      def additional_entries
        entries = []

        ENTRIES.each do |id, names|
          names.each do |name|
            entries << [name, id] if at_css("[id='#{id}']")
          end
        end

        css('h2').each do |node|
          name = node.content.strip
          next if name.in?(%w(Examples Getting\ Started Installation More\ Information Testing\ Mocha))
          name = 'mocha' if name == 'Usage'
          entries << [name, node['id']]
        end

        entries.each do |entry|
          entry[2] = entry[0] =~ /\A[a-z]/ ? 'API' : 'Manual'
        end

        entries
      end
    end
  end
end
