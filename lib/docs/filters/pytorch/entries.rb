module Docs
  class Pytorch
    class EntriesFilter < Docs::EntriesFilter
      TYPE_REPLACEMENTS = {
        "torch.Tensor" => "Tensor",
        "torch.nn" => "Neuro Network",
        "Probability distributions - torch.distributions" => "Probability Distributions",
        "torch" => "Torch",
        "Quantization" => "Quantization",
        "torch.optim" => "Optimization",
        "torch.Storage" => "Storage",
        "torch.nn.functional" => "NN Functions",
        "torch.cuda" => "CUDA",
        "Torch Distributed Elastic" => "Distributed Elastic",
        "torch.fx" => "FX",
        "TorchScript" => "Torch Script",
        "torch.onnx" => "ONNX",
        "Distributed communication package - torch.distributed" => "Distributed Communication",
        "Automatic differentiation package - torch.autograd" => "Automatic Differentiation",
        "torch.linalg" => "Linear Algebra",
        "Distributed Checkpoint - torch.distributed.checkpoint" => "Distributed Checkpoint",
        "Distributed RPC Framework" => "Distributed RPC",
        "torch.special" => "SciPy-like Special",
        "torch.package" => "Package",
        "torch.backends" => "Backends",
        "FullyShardedDataParallel" => "Fully Sharded Data Parallel",
        "torch.sparse" => "Sparse Tensors",
        "torch.export" => "Traced Graph Export",
        "torch.fft" => "Discrete Fourier Transforms",
        "torch.utils.data" => "Datasets and Data Loaders",
        "torch.monitor" => "Monitor",
        "Automatic Mixed Precision package - torch.amp" => "Automatic Mixed Precision",
        "torch.utils.tensorboard" => "Tensorboard",
        "torch.profiler" => "Profiler",
        "torch.mps" => "MPS",
        "DDP Communication Hooks" => "DDP Communication Hooks",
        "Benchmark Utils - torch.utils.benchmark" => "Benchmark Utils",
        "torch.nn.init" => "Parameter Initializations",
        "Tensor Parallelism - torch.distributed.tensor.parallel" => "Tensor Parallelism",
        "torch.func" => "JAX-like Function Transforms",
        "Distributed Optimizers" => "Distributed Optimizers",
        "torch.signal" => "SciPy-like Signal",
        "torch.futures" => "Miscellaneous",
        "torch.utils.cpp_extension" => "Miscellaneous",
        "torch.overrides" => "Miscellaneous",
        "Generic Join Context Manager" => "Miscellaneous",
        "torch.hub" => "Miscellaneous",
        "torch.cpu" => "Miscellaneous",
        "torch.random" => "Miscellaneous",
        "torch.compiler" => "Miscellaneous",
        "Pipeline Parallelism" => "Miscellaneous",
        "Named Tensors" => "Miscellaneous",
        "Multiprocessing package - torch.multiprocessing" => "Miscellaneous",
        "torch.utils" => "Miscellaneous",
        "torch.library" => "Miscellaneous",
        "Tensor Attributes" => "Miscellaneous",
        "torch.testing" => "Miscellaneous",
        "torch.nested" => "Miscellaneous",
        "Understanding CUDA Memory Usage" => "Miscellaneous",
        "torch.utils.dlpack" => "Miscellaneous",
        "torch.utils.checkpoint" => "Miscellaneous",
        "torch.__config__" => "Miscellaneous",
        "Type Info" => "Miscellaneous",
        "torch.utils.model_zoo" => "Miscellaneous",
        "torch.utils.mobile_optimizer" => "Miscellaneous",
        "torch._logging" => "Miscellaneous",
        "torch.masked" => "Miscellaneous",
        "torch.utils.bottleneck" => "Miscellaneous"
      }

      def get_breadcrumbs
        css('.pytorch-breadcrumbs > li').map {
          |node| node.content.delete_suffix(' >').strip
        }.reject { |item| item.nil? || item.empty? }
      end

      def get_name
        b = get_breadcrumbs
        b[(b[1] == 'torch' ? 2 : 1)..].join('.')
      end

      def get_type
        t = get_breadcrumbs[1]
        TYPE_REPLACEMENTS.fetch(t, t)
      end

      def include_default_entry?
        # Only include API entries to simplify and unify the list
        return name.start_with?('torch.')
      end

      def additional_entries
        return [] if root_page?

        entries = []
        css('dl').each do |node|
          dt = node.at_css('dt')
          if dt == nil
            next
          end
          id = dt['id']
          if id == name or id == nil
            next
          end

          case node['class']
          when 'py method', 'py function'
            entries << [id + '()', id]
          when 'py class', 'py attribute', 'py property'
            entries << [id, id]
          when 'footnote brackets', 'field-list simple'
            next
          end
        end

        entries
      end
    end
  end
end
