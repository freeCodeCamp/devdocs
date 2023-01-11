module Docs
  class Kubernetes
    class EntriesFilter < Docs::EntriesFilter

      def get_name
        at_css('h1').content
      end

      def get_type
        @doc.parent.css('nav .breadcrumb-item:not(.active)')[-1].content
      end

      def additional_entries
        entries = css('h2').to_a()
        # remove the Feedback section
        entries.filter! {|node| node.content.strip != 'Feedback' }
        # remove the Operations section
        entries.filter! {|node| node['id'] != 'Operations' }
        # remove the ObjectList section
        entries.filter! {|node| node['id'] != name + 'List' }
        # remove the Object section, most of the documents start with (h1.Pod => h2.Pod h2.PodSpec ...)
        entries.filter! {|node| node['id'] != name }
        
        entries.map do |node|
          # split all names into YAML object notation (ConfigMapSpec) ==> (ConfigMap.Spec)
          child_name = node.content
          if child_name.starts_with?(name) && child_name.length > name.length
            child_name = name + child_name.sub(name, '.')
          end

          [child_name, node['id']]
        end
      end

    end
  end
end
