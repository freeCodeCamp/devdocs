module Docs
  class Redis
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        slug.gsub('-', ' ')
      end

      def get_type
        case at_css('aside > ul:last-child a').content.strip
        when 'DEL'              then 'Keys'
        when 'APPEND'           then 'Strings'
        when 'HDEL'             then 'Hashes'
        when 'BLPOP'            then 'Lists'
        when 'SADD'             then 'Sets'
        when 'BZPOPMAX'         then 'Sorted Sets'
        when 'PSUBSCRIBE'       then 'Pub/Sub'
        when 'DISCARD'          then 'Transactions'
        when 'EVAL'             then 'Scripting'
        when 'AUTH'             then 'Connection'
        when 'BGREWRITEAOF'     then 'Server'
        when 'PFADD'            then 'HyperLogLog'
        when 'CLUSTER ADDSLOTS' then 'Cluster'
        when 'GEOADD'           then 'Geo'
        when 'XADD'             then 'Stream'
        else 'Miscellaneous'
        end
      end
    end
  end
end
