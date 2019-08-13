module Docs
  class Cmake
    class EntriesFilter < Docs::EntriesFilter
      NAME_BY_SLUG = {
        'manual/cmake.1' => 'CMake',
        'manual/ctest.1' => 'CTest',
        'manual/cpack.1' => 'CPack',
        'manual/cmake-gui.1' => 'CMake GUI',
        'manual/ccmake.1' => 'CCMake' }

      TYPE_BY_DIR = {
        'command' => 'Commands',
        'manual' => 'Manual',
        'module' => 'Modules',
        'policy' => 'Policies',
        'prop_cache' => 'Properties: Cache Entries',
        'prop_dir' => 'Properties: Directories',
        'prop_gbl' => 'Properties of Global Scope',
        'prop_inst' => 'Properties: Installed Files',
        'prop_sf' => 'Properties: Source Files',
        'prop_test' => 'Properties: Tests',
        'prop_tgt' => 'Properties: Targets',
        'envvar' => 'Environment Variables',
        'variable' => 'Variables' }

      def get_name
        if NAME_BY_SLUG.key?(slug)
          NAME_BY_SLUG[slug]
        elsif slug =~ /\Amanual\/cmake-([\w\-]+)\.7\z/
          $1.titleize
        else
          dir, name = slug.split('/')
          name << '()' if dir == 'command'
          name
        end
      end

      def get_type
        TYPE_BY_DIR[slug.split('/').first]
      end
    end
  end
end
