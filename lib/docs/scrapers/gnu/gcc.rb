module Docs
  class Gcc < Gnu
    self.name = 'GCC'
    self.slug = 'gcc'
    self.links = {
      home: 'https://gcc.gnu.org/'
    }

    html_filters.push 'gcc/clean_html', 'title'

    options[:root_title] = false
    options[:title] = false

    options[:replace_paths] = {
      'aarch64_002dfeature_002dmodifiers.html' => 'AArch64-Options.html',
      'AssemblerTemplate.html' => 'Extended-Asm.html',
      'AVR-Named-Address-Spaces.html' => 'Named-Address-Spaces.html',
      'AVR-Variable-Attributes.html' => 'Variable-Attributes.html',
      'Clobbers.html' => 'Extended-Asm.html',
      'dashMF.html' => 'Preprocessor-Options.html',
      'GotoLabels.html' => 'Extended-Asm.html',
      'InputOperands.html' => 'Extended-Asm.html',
      'OutputOperands.html' => 'Extended-Asm.html',
      'PowerPC-Type-Attributes.html' => 'Type-Attributes.html',
      'SPU-Type-Attributes.html' => 'Type-Attributes.html',
      'Type_002dpunning.html' => 'Optimize-Options.html',
      'Volatile.html' => 'Extended-Asm.html',
      'Wtrigraphs.html' => 'Preprocessor-Options.html',
      'x86-Type-Attributes.html' => 'Type-Attributes.html',
      'x86-Variable-Attributes.html' => 'Variable-Attributes.html',
      'x86floatingpointasmoperands.html' => 'Extended-Asm.html',
      'x86Operandmodifiers.html' => 'Extended-Asm.html',

      'Example-of-asm-with-clobbered-asm-reg.html' => 'Extended-Asm.html',
      'Extended-asm-with-goto.html' => 'Extended-Asm.html',
      'fdollars_002din_002didentifiers.html' => 'Preprocessor-Options.html',
      'i386-Type-Attributes.html' => 'Variable-Attributes.html',
      'i386-Variable-Attributes.html' => 'Variable-Attributes.html'
    }

    CPP_PATHS = {
      'dashMF.html' => 'Invocation.html',
      'fdollars_002din_002didentifiers.html' => 'Invocation.html',
      'Identifier-characters.html' => 'Implementation_002ddefined-behavior.html',
      'trigraphs.html' => 'Initial-processing.html',
      'Wtrigraphs.html' => 'Invocation.html'
    }

    version '9' do
      self.release = '9.2.0'
      self.base_url = "https://gcc.gnu.org/onlinedocs/gcc-#{release}/gcc/"
    end

    version '9 CPP' do
      self.release = '9.2.0'
      self.base_url = "https://gcc.gnu.org/onlinedocs/gcc-#{release}/cpp/"

      options[:replace_paths] = CPP_PATHS
    end

    version '8' do
      self.release = '8.3.0'
      self.base_url = "https://gcc.gnu.org/onlinedocs/gcc-#{release}/gcc/"
    end

    version '8 CPP' do
      self.release = '8.3.0'
      self.base_url = "https://gcc.gnu.org/onlinedocs/gcc-#{release}/cpp/"

      options[:replace_paths] = CPP_PATHS
    end

    version '7' do
      self.release = '7.4.0'
      self.base_url = "https://gcc.gnu.org/onlinedocs/gcc-#{release}/gcc/"
    end

    version '7 CPP' do
      self.release = '7.4.0'
      self.base_url = "https://gcc.gnu.org/onlinedocs/gcc-#{release}/cpp/"

      options[:replace_paths] = CPP_PATHS
    end

    version '6' do
      self.release = '6.4.0'
      self.base_url = "https://gcc.gnu.org/onlinedocs/gcc-#{release}/gcc/"

      options[:root_title] = 'Using the GNU Compiler Collection (GCC)'
    end

    version '6 CPP' do
      self.release = '6.4.0'
      self.base_url = "https://gcc.gnu.org/onlinedocs/gcc-#{release}/cpp/"

      options[:replace_paths] = CPP_PATHS
    end

    version '5' do
      self.release = '5.4.0'
      self.base_url = "https://gcc.gnu.org/onlinedocs/gcc-#{release}/gcc/"

      options[:root_title] = 'Using the GNU Compiler Collection (GCC)'
    end

    version '5 CPP' do
      self.release = '5.4.0'
      self.base_url = "https://gcc.gnu.org/onlinedocs/gcc-#{release}/cpp/"

      options[:replace_paths] = CPP_PATHS
    end

    version '4' do
      self.release = '4.9.3'
      self.base_url = "https://gcc.gnu.org/onlinedocs/gcc-#{release}/gcc/"

      options[:root_title] = 'Using the GNU Compiler Collection (GCC)'
    end

    version '4 CPP' do
      self.release = '4.9.3'
      self.base_url = "https://gcc.gnu.org/onlinedocs/gcc-#{release}/cpp/"

      options[:replace_paths] = CPP_PATHS
    end

    def get_latest_version(opts)
      doc = fetch_doc('https://gcc.gnu.org/onlinedocs/', opts)
      label = doc.at_css('ul > li > ul > li > a').content.strip
      label.scan(/([0-9.]+)/)[0][0]
    end
  end
end
