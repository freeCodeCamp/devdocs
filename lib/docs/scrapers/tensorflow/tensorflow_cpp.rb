module Docs
  class TensorflowCpp < Tensorflow
    self.name = 'TensorFlow C++'
    self.slug = 'tensorflow_cpp'

    version '2.3' do
      self.release = "#{version}.0"
      self.base_url = "https://www.tensorflow.org/versions/r#{version}/api_docs/cc"
    end

    version '1.15' do
      self.release = "#{version}.0"
      self.base_url = "https://www.tensorflow.org/versions/r#{version}/api_docs/cc"
    end

  end
end
