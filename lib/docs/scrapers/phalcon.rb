module Docs
  class Phalcon < UrlScraper
    self.type = 'phalcon'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://phalconphp.com/',
      code: 'https://github.com/phalcon/cphalcon/'
    }

    html_filters.push 'phalcon/clean_html', 'phalcon/entries'

    options[:root_title] = 'Phalcon'

    options[:attribution] = <<-HTML
      &copy; 2011&ndash;2017 Phalcon Framework Team<br>
      Licensed under the Creative Commons Attribution License 3.0.
    HTML

    options[:trailing_slash] = true

    version '4' do
      self.release = '4.0'
      self.base_url = "https://docs.phalcon.io/#{self.release}/en/api"
    end

    version '3' do
      self.release = '3.4'
      self.base_url = "https://docs.phalcon.io/#{self.release}/en/api"

      options[:fix_urls] = -> (url) do
        url.sub!('Phalcon_Application_Exception', 'Phalcon_Application')
        url.sub!('Phalcon_CryptInterface', 'Phalcon_Crypt')
        url.sub!('Phalcon_Crypt_Mismatch', 'Phalcon_Crypt')
        url.sub!('Phalcon_Crypt_Exception', 'Phalcon_Crypt')
        url.sub!('Phalcon_EscaperInterface', 'Phalcon_Escaper')
        url.sub!('Phalcon_Loader_Exception', 'Phalcon_Loader')
        url.sub!('Phalcon_Mvc_CollectionInterface', 'Phalcon_Mvc_Collection')
        url.sub!('Phalcon_Mvc_Collection_ManagerInterface', 'Phalcon_Mvc_Collection')
        url.sub!('Phalcon_Mvc_Collection_BehaviorInterface', 'Phalcon_Mvc_Collection')
        url.sub!('Phalcon_Mvc_Collection_Behavior', 'Phalcon_Mvc_Collection')
        url.sub!('Phalcon_Mvc_ControllerInterface', 'Phalcon_Mvc_Controller')
        url.sub!('Phalcon_Mvc_DispatcherInterface', 'Phalcon_Mvc_Dispatcher')
        url.sub!('Phalcon_Mvc_Micro_Collection', 'Phalcon_Mvc_Micro')
        url.sub!('Phalcon_Mvc_Micro_CollectionInterface', 'Phalcon_Mvc_Micro')
        url.sub!('Phalcon_Mvc_ModelInterface', 'Phalcon_Mvc_Model')
        url.sub!('Phalcon_Mvc_BehaviorInterface', 'Phalcon_Mvc_Behavior')
        url.sub!('Phalcon_Mvc_Model_BinderInterface', 'Phalcon_Mvc_Model_Binder')
        url.sub!('Phalcon_Mvc_Model_Managerinterface', 'Phalcon_Mvc_Model_Manager')
        url.sub!('Phalcon_Mvc_Model_MessageInterface', 'Phalcon_Mvc_Model_Message')
        url.sub!('Phalcon_Mvc_Model_QueryInterface', 'Phalcon_Mvc_Model_Query')
        url.sub!('Phalcon_Mvc_Model_Query_StatusInterface', 'Phalcon_Mvc_Model_Query')
        url.sub!('Phalcon_Mvc_Model_Query_Builder', 'Phalcon_Mvc_Model_Query')
        url.sub!('Phalcon_Mvc_Model_Query_BuilderInterface', 'Phalcon_Mvc_Model_Query')
        url.sub!('Phalcon_Mvc_Model_RelationInterface', 'Phalcon_Mvc_Model_Relation')
        url.sub!('Phalcon_Mvc_Model_ResulsetInterface', 'Phalcon_Mvc_Model_Resulset')
        url.sub!('Phalcon_Mvc_Model_Resulset_Simple', 'Phalcon_Mvc_Model_Resulset')
        url.sub!('Phalcon_Mvc_Model_TransactionInterface', 'Phalcon_Mvc_Model_Transaction')
        url.sub!('Phalcon_Mvc_Model_Transaction_ManagerInterface', 'Phalcon_Mvc_Model_Transaction')
        url.sub!('Phalcon_Mvc_Model_Transaction_Exception', 'Phalcon_Mvc_Model_Transaction')
        url.sub!('Phalcon_Mvc_Model_ValidatorInterface', 'Phalcon_Mvc_Model_Validator')
        url.sub!('Phalcon_Mvc_Router_RouteInterface', 'Phalcon_Mvc_Router')
        url.sub!('Phalcon_Mvc_RouterInterface', 'Phalcon_Mvc_Router')
        url.sub!('Phalcon_Mvc_Router_Route', 'Phalcon_Mvc_Router')
        url.sub!('Phalcon_Mvc_Router_GroupInterface', 'Phalcon_Mvc_Router')
        url.sub!('Phalcon_Mvc_UrlInterface', 'Phalcon_Mvc_Url')
        url.sub!('Phalcon_Mvc_ViewBaseInterface', 'Phalcon_Mvc_View')
        url.sub!('Phalcon_Mvc_ViewInterface', 'Phalcon_Mvc_View')
        url.sub!('Phalcon_Mvc_View_EngineInterface', 'Phalcon_Mvc_View')
        url.sub!('Phalcon_Mvc_View_Engine', 'Phalcon_Mvc_View')
        url.sub!('Phalcon_Mvc_View_Exception', 'Phalcon_Mvc_View')
        url.sub!('Phalcon_Queue_Beanstalk', 'Phalcon_Queue')
        url
      end

    end

    def get_latest_version(opts)
      doc = fetch_doc('https://docs.phalconphp.com/', opts)
      doc.css('.header-dropdown-wrapper').remove
      doc.at_css('.header__right > .header__lang').content.strip
    end

  end
end
