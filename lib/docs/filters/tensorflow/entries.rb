# frozen_string_literal: true

module Docs
  class Tensorflow
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content.strip
        name.remove! 'class '
        name.remove! 'struct '
        name.remove! 'Module: '
        name.remove! %r{ \(.+\)}
        name.sub! %r{(?<!\ )\(.+\)}, '()'
        name.remove! %r{\.\z}
        name
      end

      def get_type
        if version == 'Guide' and base_url.path.start_with?('/guide')
          'Guides'
        elsif version == 'Guide' and base_url.path.start_with?('/tutorials')
          'Tutorials'
        elsif slug.start_with?('tf/audio')
          'tf.audio'
        elsif slug.start_with?('tf/autograph')
          'tf.autograph'
        elsif slug.start_with?('tf/bitwise')
          'tf.bitwise'
        elsif slug.start_with?('tf/compat')
          'tf.compat'
        elsif slug.start_with?('tf/config')
          'tf.config'
        elsif slug.start_with?('tf/data')
          'tf.data'
        elsif slug.start_with?('tf/debugging')
          'tf.debugging'
        elsif slug.start_with?('tf/distribute')
          'tf.distribute'
        elsif slug.start_with?('tf/dtypes')
          'tf.dtypes'
        elsif slug.start_with?('tf/errors')
          'tf.errors'
        elsif slug.start_with?('tf/estimator')
          'tf.estimator'
        elsif slug.start_with?('tf/experimental')
          'tf.experimental'
        elsif slug.start_with?('tf/feature_column')
          'tf.feature_column'
        elsif slug.start_with?('tf/graph_util')
          'tf.graph_util'
        elsif slug.start_with?('tf/image')
          'tf.image'
        elsif slug.start_with?('tf/initializers')
          'tf.initializers'
        elsif slug.start_with?('tf/io')
          'tf.io'
        elsif slug.start_with?('tf/keras')
          'tf.keras'
        elsif slug.start_with?('tf/linalg')
          'tf.linalg'
        elsif slug.start_with?('tf/lite')
          'tf.lite'
        elsif slug.start_with?('tf/lookup')
          'tf.lookup'
        elsif slug.start_with?('tf/losses')
          'tf.losses'
        elsif slug.start_with?('tf/math')
          'tf.math'
        elsif slug.start_with?('tf/metrics')
          'tf.metrics'
        elsif slug.start_with?('tf/nest')
          'tf.nest'
        elsif slug.start_with?('tf/nn')
          'tf.nn'
        elsif slug.start_with?('tf/optimizers')
          'tf.optimizers'
        elsif slug.start_with?('tf/quantization')
          'tf.quantization'
        elsif slug.start_with?('tf/queue')
          'tf.queue'
        elsif slug.start_with?('tf/ragged')
          'tf.ragged'
        elsif slug.start_with?('tf/random')
          'tf.random'
        elsif slug.start_with?('tf/raw_ops')
          'tf.raw_ops'
        elsif slug.start_with?('tf/saved_model')
          'tf.saved_model'
        elsif slug.start_with?('tf/sets')
          'tf.sets'
        elsif slug.start_with?('tf/signal')
          'tf.signal'
        elsif slug.start_with?('tf/sparse')
          'tf.sparse'
        elsif slug.start_with?('tf/strings')
          'tf.strings'
        elsif slug.start_with?('tf/summary')
          'tf.summary'
        elsif slug.start_with?('tf/sysconfig')
          'tf.sysconfig'
        elsif slug.start_with?('tf/test')
          'tf.test'
        elsif slug.start_with?('tf/tpu')
          'tf.tpu'
        elsif slug.start_with?('tf/train')
          'tf.train'
        elsif slug.start_with?('tf/version')
          'tf.version'
        elsif slug.start_with?('tf/xla')
          'tf.xla'
        else
          'tf'
        end
      end
    end
  end
end
