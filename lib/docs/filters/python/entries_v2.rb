module Docs
  class Python
    class EntriesV2Filter < CommonEntriesFilter
      REPLACE_TYPES = {
        'compiler package'                        => 'Compiler',
        'Cryptographic'                           => 'Cryptography',
        'Custom Interpreters'                     => 'Interpreters',
        'Data Compression & Archiving'            => 'Data Compression',
        'Generic Operating System'                => 'Operating System',
        'Graphical User Interfaces with Tk'       => 'Tk',
        'Internet Data Handling'                  => 'Internet Data',
        'Internet Protocols & Support'            => 'Internet',
        'Interprocess Communication & Networking' => 'Networking',
        'MacOSA'                                  => 'Mac OS',
        'Program Frameworks'                      => 'Frameworks',
        'Structured Markup Processing Tools'      => 'Structured Markup' }

      def parse_type(type)
        if type.start_with? '18'
          type = 'Internet Data Handling'
        elsif type.include? 'Mac'
          type = 'Mac OS'
        end

        type
      end

      def include_default_entry?
        super && type != 'SunOS'
      end
    end
  end
end
