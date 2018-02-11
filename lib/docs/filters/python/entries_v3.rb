module Docs
  class Python
    class EntriesV3Filter < CommonEntriesFilter
      REPLACE_TYPES = {
        'Cryptographic'                           => 'Cryptography',
        'Custom Interpreters'                     => 'Interpreters',
        'Data Compression & Archiving'            => 'Data Compression',
        'Generic Operating System'                => 'Operating System',
        'Graphical User Interfaces with Tk'       => 'Tk',
        'Internet Data Handling'                  => 'Internet Data',
        'Internet Protocols & Support'            => 'Internet',
        'Interprocess Communication & Networking' => 'Networking',
        'Program Frameworks'                      => 'Frameworks',
        'Structured Markup Processing Tools'      => 'Structured Markup' }

      def parse_type(type)
        if type.start_with? '19'
          type = 'Internet Data Handling'
        end

        type
      end
    end
  end
end
