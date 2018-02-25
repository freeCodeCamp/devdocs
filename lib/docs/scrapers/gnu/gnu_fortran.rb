module Docs
  class GnuFortran < Gnu
    self.name = 'GNU Fortran'
    self.slug = 'gnu_fortran'
    self.links = {
      home: 'https://gcc.gnu.org/fortran/'
    }

    version '7' do
      self.release = '7.3.0'
      self.dir = '/Users/Thibaut/DevDocs/Docs/gfortran7'
      self.base_url = "https://gcc.gnu.org/onlinedocs/gcc-#{release}/gfortran/"
    end

    version '6' do
      self.release = '6.4.0'
      self.dir = '/Users/Thibaut/DevDocs/Docs/gfortran6'
      self.base_url = "https://gcc.gnu.org/onlinedocs/gcc-#{release}/gfortran/"
    end

    version '5' do
      self.release = '5.4.0'
      self.dir = '/Users/Thibaut/DevDocs/Docs/gfortran5'
      self.base_url = "https://gcc.gnu.org/onlinedocs/gcc-#{release}/gfortran/"
    end

    version '4' do
      self.release = '4.9.3'
      self.dir = '/Users/Thibaut/DevDocs/Docs/gfortran4'
      self.base_url = "https://gcc.gnu.org/onlinedocs/gcc-#{release}/gfortran/"
    end
  end
end
