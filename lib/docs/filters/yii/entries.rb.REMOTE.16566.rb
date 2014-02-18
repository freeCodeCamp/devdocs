module Docs
  class Yii
    class EntriesFilter < Docs::EntriesFilter
     
      def get_name
        #class names exist in the <h1> content.
        name = at_css('h1').content.strip 
      end
      
      def get_type
        #need to get the table with a class of summaryTable. Then we need the content of the first td in the first tr.
	    type = css('table.summaryTable td')[0].content
		type
      end
      
      def additional_entries
      	css('table.summaryTable tr[id]').inject [] do |entries,node|
      	#need to ignore inherited methods and properties
      	  if (node['class'] != 'inherited' and node.parent().parent()['class'] == "summary docMethod")
      	    #name should be Class.method() id will take you to the link in the summary block.
      	    name = slug + "." + node['id'] + "()"
      	    entries << [name, node['id']]
		  end			
       	  entries
        end   
      end  
         
    end
  end
end