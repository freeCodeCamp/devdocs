module Docs
  class TensorflowGuide < Tensorflow
    include MultipleBaseUrls

    self.name = 'TensorFlow Guides'
    self.slug = 'tensorflow_guide'
    self.base_urls = ['https://www.tensorflow.org/guide/', 'https://www.tensorflow.org/tutorials/']
  end
end
