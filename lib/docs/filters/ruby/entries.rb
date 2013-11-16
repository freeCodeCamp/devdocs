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
        type = super

        REPLACE_TYPE_STARTS_WITH.each_pair do |key, value|
          return value if type.start_with?(key)
        end

        REPLACE_TYPE_ENDS_WITH.each_pair do |key, value|
          return value if type.end_with?(key)
        end

        REPLACE_TYPE[type] || type
      end
    end
  end
end
