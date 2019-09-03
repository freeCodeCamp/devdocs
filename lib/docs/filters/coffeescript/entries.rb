module Docs
  class Coffeescript
    class EntriesFilter < Docs::EntriesFilter
      ENTRIES = [
        ['coffee command',              'cli',                      'Miscellaneous'],
        ['->',                          'functions',                'Statements'],
        ['await',                       'async-functions',          'Statements'],
        ['if...then...else',            'conditionals',             'Statements'],
        ['unless',                      'conditionals',             'Statements'],
        ['... splats',                  'splats',                   'Language'],
        ['for...in',                    'loops',                    'Statements'],
        ['for...in...by',               'loops',                    'Statements'],
        ['for...in...when',             'loops',                    'Statements'],
        ['for...of',                    'loops',                    'Statements'],
        ['while',                       'loops',                    'Statements'],
        ['until',                       'loops',                    'Statements'],
        ['loop',                        'loops',                    'Statements'],
        ['do',                          'loops',                    'Statements'],
        ['Ranges',                      'slices',                   'Language'],
        ['?',                           'existential-operator',     'Operators'],
        ['?=',                          'existential-operator',     'Operators'],
        ['?.',                          'existential-operator',     'Operators'],
        ['class',                       'classes',                  'Statements'],
        ['extends',                     'classes',                  'Statements'],
        ['super',                       'classes',                  'Statements'],
        ['::',                          'prototypal-inheritance',   'Operators'],
        ['=>',                          'fat-arrow',                'Statements'],
        ['yield',                       'generators',               'Statements'],
        ['switch...when...else',        'switch',                   'Statements'],
        ['try...catch...finally',       'try',                      'Statements'],
        ['#{} interpolation',           'strings',                  'Language'],
        ['Block strings',               'strings',                  'Language'],
        ['"""',                         'strings',                  'Language'],
        ['###',                         'comments',                 'Language'],
        ['###::',                       'type-annotations',         'Language'],
        ['///',                         'regexes',                  'Language'],
        ['import',                      'modules',                  'Language'],
        ['export',                      'modules',                  'Language']
      ]

      def additional_entries
        entries = []

        ENTRIES.each do |entry|
          raise "entry not found: #{entry.inspect}" unless at_css("[id='#{entry[1]}']")
          entries << entry
        end

        css('.navbar > nav > .nav-link').each do |node|
          name = node.content.strip
          next if name.in?(%w(Overview Changelog Introduction)) || !node['href'].start_with?('#')
          entries << [name, node['href'].remove('#'), 'Miscellaneous']

          if name == 'Language Reference'
            node.next_element.css('.nav-link').each do |n|
              entries << [n.content, n['href'].remove('#'), name]
            end
          end
        end

        at_css('#operators table').css('td:first-child > code').each do |node|
          name = node.content.strip
          next if %w(true false yes no on off this).include?(name)
          name.sub! %r{\Aa (.+) b\z}, '\1'
          name = 'for...from' if name == 'for a from b'
          id = name_to_id(name)
          node['id'] = id
          entries << [name, id, 'Operators']
        end

        entries
      end

      def name_to_id(name)
        case name
          when '**' then 'pow'
          when '//' then 'floor'
          when '%%' then 'mod'
          when '@' then 'this'
          else name.parameterize
        end
      end
    end
  end
end
