module Docs
  class Mocha
    class EntriesFilter < Docs::EntriesFilter
      ENTRIES = {
        'asynchronous-code' => ['done()'],
        'hooks' => ['before()', 'after()', 'beforeEach()', 'afterEach()', 'suiteSetup()', 'suiteTeardown()', 'setup()', 'teardown()'],
        'exclusive-tests' => ['only()'],
        'inclusive-tests' => ['skip()'],
        'usage' => ['mocha'],
        'bdd-interface' => ['describe()', 'context()', 'it()'],
        'tdd-interface' => ['suite()', 'test()'],
        'exports-interface' => ['exports'],
        'qunit-interface' => ['QUnit'],
        'require-interface' => ['require'],
        'browser-setup' => ['setup()'],
        'mocha.opts' => ['mocha.opts'],
        'suite-specific-timeouts' => ['timeout()']
      }

      def additional_entries
        ENTRIES.each_with_object [] do |(id, names), entries|
          type = case id
            when 'hooks' then 'Hooks'
            when /interface/ then 'Interfaces'
            else 'Miscellaneous' end

          names.each do |name|
            entries << [name, id, type]
          end
        end
      end
    end
  end
end
