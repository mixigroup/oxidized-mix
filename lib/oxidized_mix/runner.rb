module OxidizedMix
  # call Node#run and write to the path
  class Runner
    def initialize(path)
      @path = path
      @node = ::Oxidized::Nodes.new(node: File.basename(@path)).first
    end

    def run
      print "Save #{@node.name} ... "

      status, config = @node.run
      if status == :success
        File.write @path, config.to_cfg
        puts 'done'
      else
        puts 'failed'
      end
    end
  end
end
