module Docs
  class Cmake
    class EntriesFilter < Docs::EntriesFilter
      MISCELLANEOUS = {
        'manual/cmake.1' => 'CMake',
        'manual/ctest.1' => 'CTest',
        'manual/cpack.1' => 'CPack',
        'manual/cmake-gui.1' => 'CMake GUI',
        'manual/ccmake.1' => 'CCMake',
        'manual/cmake-buildsystem.7' => 'Buildsystem',
        'manual/cmake-commands.7' => 'Commands',
        'manual/cmake-compile-features.7' => 'Compile Features',
        'manual/cmake-developer.7' => 'Developer',
        'manual/cmake-generator-expressions.7' => 'Generator Expressions',
        'manual/cmake-generators.7' => 'Generators',
        'manual/cmake-language.7' => 'Language',
        'manual/cmake-modules.7' => 'Modules',
        'manual/cmake-packages.7' => 'Packages',
        'manual/cmake-policies.7' => 'Policies',
        'manual/cmake-properties.7' => 'Properties',
        'manual/cmake-qt.7' => 'Qt',
        'manual/cmake-toolchains.7' => 'Toolchains',
        'manual/cmake-variables.7' => 'Variables' }

      GROUPS = {
        'command' => 'Commands',
        'policy' => 'Policies',
        'prop_gbl' => 'Properties of Global Scope',
        'prop_dir' => 'Properties on Directories',
        'prop_tgt' => 'Properties on Targets',
        'prop_test' => 'Properties on Tests',
        'prop_sf' => 'Properties on Source Files',
        'prop_cache' => 'Properties on Cache Entries',
        'prop_inst' => 'Properties on Installed Files',
        'variable' => 'Variables' }

      def get_name
        if MISCELLANEOUS.key?(slug)
          return MISCELLANEOUS[slug]
        end
        parts = slug.split('/')
        name = parts.drop(1).first
        if name == ''
          return slug
        end
        if parts.first == 'command'
          name += '()'
        end
        name
      end

      def get_type
        if MISCELLANEOUS.key?(slug)
          return 'Miscellaneous'
        end
        parts = slug.split('/')
        if GROUPS.key?(parts.first)
          return GROUPS[parts.first]
        end
        slug
      end
    end
  end
end
