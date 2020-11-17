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
        if slug.start_with?('audio')
          'tf.audio'
        elsif slug.start_with?('autodiff')
          'tf.autodiff'
        elsif slug.start_with?('autograph')
          'tf.autograph'
        elsif slug.start_with?('bitwise')
          'tf.bitwise'
        elsif slug.start_with?('compat')
          'tf.compat'
        elsif slug.start_with?('config')
          'tf.config'
        elsif slug.start_with?('data')
          'tf.data'
        elsif slug.start_with?('debugging')
          'tf.debugging'
        elsif slug.start_with?('distribute')
          'tf.distribute'
        elsif slug.start_with?('dtypes')
          'tf.dtypes'
        elsif slug.start_with?('errors')
          'tf.errors'
        elsif slug.start_with?('estimator')
          'tf.estimator'
        elsif slug.start_with?('experimental')
          'tf.experimental'
        elsif slug.start_with?('feature_column')
          'tf.feature_column'
        elsif slug.start_with?('graph_util')
          'tf.graph_util'
        elsif slug.start_with?('image')
          'tf.image'
        elsif slug.start_with?('initializers')
          'tf.initializers'
        elsif slug.start_with?('io')
          'tf.io'
        elsif slug.start_with?('keras')
          'tf.keras'
        elsif slug.start_with?('linalg')
          'tf.linalg'
        elsif slug.start_with?('lite')
          'tf.lite'
        elsif slug.start_with?('lookup')
          'tf.lookup'
        elsif slug.start_with?('losses')
          'tf.losses'
        elsif slug.start_with?('math')
          'tf.math'
        elsif slug.start_with?('metrics')
          'tf.metrics'
        elsif slug.start_with?('mixed_precision')
          'tf.mixed_precision'
        elsif slug.start_with?('mlir')
          'tf.mlir'
        elsif slug.start_with?('nest')
          'tf.nest'
        elsif slug.start_with?('nn')
          'tf.nn'
        elsif slug.start_with?('optimizers')
          'tf.optimizers'
        elsif slug.start_with?('profiler')
          'tf.profiler'
        elsif slug.start_with?('quantization')
          'tf.quantization'
        elsif slug.start_with?('queue')
          'tf.queue'
        elsif slug.start_with?('ragged')
          'tf.ragged'
        elsif slug.start_with?('random')
          'tf.random'
        elsif slug.start_with?('raw_ops')
          'tf.raw_ops'
        elsif slug.start_with?('saved_model')
          'tf.saved_model'
        elsif slug.start_with?('sets')
          'tf.sets'
        elsif slug.start_with?('signal')
          'tf.signal'
        elsif slug.start_with?('sparse')
          'tf.sparse'
        elsif slug.start_with?('strings')
          'tf.strings'
        elsif slug.start_with?('summary')
          'tf.summary'
        elsif slug.start_with?('sysconfig')
          'tf.sysconfig'
        elsif slug.start_with?('test')
          'tf.test'
        elsif slug.start_with?('tpu')
          'tf.tpu'
        elsif slug.start_with?('train')
          'tf.train'
        elsif slug.start_with?('version')
          'tf.version'
        elsif slug.start_with?('xla')
          'tf.xla'
        else
          'tf'
        end
      end
    end
  end
end
