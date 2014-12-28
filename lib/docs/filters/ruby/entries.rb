module Docs
  class Ruby
    class EntriesFilter < Docs::Rdoc::EntriesFilter
      REPLACE_TYPE = {
        'ACL'               => 'DRb',
        'Addrinfo'          => 'Socket',
        'BigMath'           => 'BigDecimal',
        'CMath'             => 'Math',
        'ConditionVariable' => 'Mutex',
        'DEBUGGER__'        => 'Debug',
        'Errno'             => 'Errors',
        'FileTest'          => 'File',
        'Jacobian'          => 'BigDecimal',
        'LUSolve'           => 'BigDecimal',
        'Newton'            => 'BigDecimal',
        'PP'                => 'PrettyPrint',
        'Profiler__'        => 'Profiler',
        'Psych'             => 'YAML',
        'Rinda'             => 'DRb',
        'SimpleDelegator'   => 'Delegator',
        'SingleForwardable' => 'Forwardable',
        'SortedSet'         => 'Set',
        'TCPServer'         => 'Socket',
        'TempIO'            => 'Tempfile',
        'ThWait'            => 'Thread',
        'UNIXServer'        => 'Socket' }

      REPLACE_TYPE_STARTS_WITH = {
        'Monitor' => 'Monitor',
        'Mutex'   => 'Mutex',
        'Shell'   => 'Shell',
        'Sync'    => 'Sync',
        'Thread'  => 'Thread' }

      REPLACE_TYPE_ENDS_WITH = {
        'Queue'  => 'Queue',
        'Socket' => 'Socket' }

      def get_type
        return 'Language' if guide?
        return $1 if name =~ /\A(Net\:\:(?:FTP|HTTP|IMAP|SMTP))/

        type = super

        REPLACE_TYPE_STARTS_WITH.each_pair do |key, value|
          return value if type.start_with?(key)
        end

        REPLACE_TYPE_ENDS_WITH.each_pair do |key, value|
          return value if type.end_with?(key)
        end

        REPLACE_TYPE[type] || type
      end

      def additional_entries
        return super unless guide?

        if slug == 'syntax/control_expressions_rdoc' || slug == 'syntax/miscellaneous_rdoc'
          css('h2 > code').each_with_object([]) do |node, entries|
            name = node.content.strip
            entries << [name, node.parent['id'], 'Syntax'] unless entries.any? { |e| e[0] == name }
          end
        elsif slug == 'globals_rdoc'
          css('dt').map do |node|
            name = node['id'] = node.content.strip
            [name, name, 'Globals']
          end
        else
          []
        end
      end

      def include_default_entry?
        guide? || super
      end

      def guide?
        slug =~ /[^\/]+_rdoc/
      end
    end
  end
end
