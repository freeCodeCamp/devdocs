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
        'require' => ['require'],
        'running-mocha-in-the-browser' => ['mocha.setup()', 'mocha.run()', 'mocha.globals()', 'mocha.checkLeaks()'],
        'timeouts' => ['timeout()'],
        'delayed-root-suite' => ['run()'],
        'command-line-usage' => ['mocha cli options']
      }

      def additional_entries
        entries = []

        ENTRIES.each do |id, names|
          names.each do |name|
            entries << [name, id] if at_css("[id='#{id}']")
          end
        end

        css('h2, h3').each do |node|
          name = node.content.strip
          next if name.match?(/\A-/)
          next if name.in?(%w(Examples Getting\ Started Installation More\ Information Testing\ Mocha))
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
