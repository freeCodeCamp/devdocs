module Docs
  class TensorflowCpp < Tensorflow
    self.name = 'TensorFlow C++'
    self.slug = 'tensorflow_cpp'

    version '2.1' do
      self.release = '2.1.0'
      self.base_url = "https://www.tensorflow.org/versions/r#{version}/api_docs/cc"
    end

    version '2.0' do
      self.release = '2.0.0'
      self.base_url = "https://www.tensorflow.org/versions/r#{version}/api_docs/cc"
    end

    version '1.15' do
      self.release = '1.15.0'
      self.base_url = "https://www.tensorflow.org/versions/r#{version}/api_docs/cc"
    end
  end
end
