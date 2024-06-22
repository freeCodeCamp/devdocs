module Docs
  class GnuFortran < Gnu
    self.name = 'GNU Fortran'
    self.slug = 'gnu_fortran'
    self.links = {
      home: 'https://gcc.gnu.org/fortran/'
    }

    version '13' do
      self.release = '13.1.0'
      self.base_url = "https://gcc.gnu.org/onlinedocs/gcc-#{release}/gfortran/"
    end

    version '12' do
      self.release = '12.1.0'
      self.base_url = "https://gcc.gnu.org/onlinedocs/gcc-#{release}/gfortran/"
    end

    version '11' do
      self.release = '11.1.0'
      self.base_url = "https://gcc.gnu.org/onlinedocs/gcc-#{release}/gfortran/"
    end

    version '10' do
      self.release = '10.2.0'
      self.base_url = "https://gcc.gnu.org/onlinedocs/gcc-#{release}/gfortran/"
    end

    version '9' do
      self.release = '9.3.0'
      self.base_url = "https://gcc.gnu.org/onlinedocs/gcc-#{release}/gfortran/"
    end

    version '8' do
      self.release = '8.4.0'
      self.base_url = "https://gcc.gnu.org/onlinedocs/gcc-#{release}/gfortran/"
    end

    version '7' do
      self.release = '7.3.0'
      self.base_url = "https://gcc.gnu.org/onlinedocs/gcc-#{release}/gfortran/"
    end

    version '6' do
      self.release = '6.4.0'
      self.base_url = "https://gcc.gnu.org/onlinedocs/gcc-#{release}/gfortran/"
    end

    version '5' do
      self.release = '5.4.0'
      self.base_url = "https://gcc.gnu.org/onlinedocs/gcc-#{release}/gfortran/"
    end

    version '4' do
      self.release = '4.9.3'
      self.base_url = "https://gcc.gnu.org/onlinedocs/gcc-#{release}/gfortran/"
    end

    def get_latest_version(opts)
      doc = fetch_doc('https://gcc.gnu.org/onlinedocs/', opts)
      label = doc.at_css('details > ul > li > a')['href'].strip
      label.scan(/([0-9.]+)/)[2..-1][0][0]
    end
  end
end
