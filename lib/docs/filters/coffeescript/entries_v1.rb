module Docs
  class Coffeescript
    class EntriesV1Filter < Docs::EntriesFilter
      ENTRIES = [
        ['coffee command',              'usage',                    'Miscellaneous'],
        ['Literate mode',               'literate',                 'Miscellaneous'],
        ['Functions',                   'literals',                 'Language'],
        ['->',                          'literals',                 'Statements'],
        ['Objects and arrays',          'objects-and-arrays',       'Language'],
        ['Lexical scoping',             'lexical-scope',            'Language'],
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
        ['Array slicing and splicing',  'slices',                   'Language'],
        ['Ranges',                      'slices',                   'Language'],
        ['Expressions',                 'expressions',              'Language'],
        ['?',                           'existential-operator',     'Operators'],
        ['?=',                          'existential-operator',     'Operators'],
        ['?.',                          'existential-operator',     'Operators'],
        ['class',                       'classes',                  'Statements'],
        ['extends',                     'classes',                  'Operators'],
        ['super',                       'classes',                  'Statements'],
        ['::',                          'classes',                  'Operators'],
        ['Destructuring assignment',    'destructuring',            'Language'],
        ['Bound Functions',             'fat-arrow',                'Language'],
        ['Generator Functions',         'fat-arrow',                'Language'],
        ['=>',                          'fat-arrow',                'Statements'],
        ['yield',                       'fat-arrow',                'Statements'],
        ['for...from',                  'fat-arrow',                'Statements'],
        ['Embedded JavaScript',         'embedded',                 'Language'],
        ['switch...when...else',        'switch',                   'Statements'],
        ['try...catch...finally',       'try-catch',                'Statements'],
        ['Chained comparisons',         'comparisons',              'Language'],
        ['#{} interpolation',           'strings',                  'Language'],
        ['Block strings',               'strings',                  'Language'],
        ['"""',                         'strings',                  'Language'],
        ['Block comments',              'strings',                  'Language'],
        ['###',                         'strings',                  'Language'],
        ['Tagged Template Literals',    'tagged-template-literals', 'Language'],
        ['Block regexes',               'regexes',                  'Language'],
        ['///',                         'regexes',                  'Language'],
        ['Modules',                     'modules',                  'Language'],
        ['import',                      'modules',                  'Language'],
        ['export',                      'modules',                  'Language'],
        ['cake command',                'cake',                     'Miscellaneous'],
        ['Cakefile',                    'cake',                     'Miscellaneous'],
        ['Source maps',                 'source-maps',              'Miscellaneous']
      ]

      def additional_entries
        entries = ENTRIES.dup

        # Operators
        at_css('#operators ~ table').css('td:first-child > code').each do |node|
          node.content.split(', ').each do |name|
            next if %w(true false yes no on off this).include?(name)
            name.sub! %r{\Aa (.+) b\z}, '\1'
            id = name_to_id(name)
            node['id'] = id
            entries << [name, id, 'Operators']
          end
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
