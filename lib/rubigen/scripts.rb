require File.dirname(__FILE__) + '/options' unless Object.const_defined?("RubiGen") && RubiGen.const_defined?("Base")

module RubiGen
  module Scripts

    # Generator scripts handle command-line invocation.  Each script
    # responds to an invoke! class method which handles option parsing
    # and generator invocation.
    class Base
      include Options
      default_options :collision => :ask, :quiet => false
      attr_reader :stdout

      # Run the generator script.  Takes an array of unparsed arguments
      # and a hash of parsed arguments, takes the generator as an option
      # or first remaining argument, and invokes the requested command.
      def run(args = [], runtime_options = {})
        @stdout = runtime_options[:stdout] || $stdout
        begin
          parse!(args.dup, runtime_options)
        rescue OptionParser::InvalidOption => e
          # Don't cry, script. Generators want what you think is invalid.
        end

        # Generator name is the only required option.
        unless options[:generator]
          usage if args.empty?
          options[:generator] ||= args.shift
        end

        # Look up generator instance and invoke command on it.
        RubiGen::Base.instance(options[:generator], args, options).command(options[:command]).invoke!
      rescue => e
        stdout.puts e
        stdout.puts "  #{e.backtrace.join("\n  ")}\n" if options[:backtrace]
        raise SystemExit unless options[:no_exit]
      end

      protected
        # Override with your own script usage banner.
        def banner
          "Usage: #{$0} generator [options] [args]"
        end

        def usage_message
          usage = "\nInstalled Generators\n"
          RubiGen::Base.sources.inject([]) do |mem, source|
            # Using an association list instead of a hash to preserve order,
            # for aesthetic reasons more than anything else.
            label = source.label.to_s.capitalize
            pair = mem.assoc(label)
            mem << (pair = [label, []]) if pair.nil?
            pair[1] |= source.names(:visible)
            mem
          end.each do |label, names|
            usage << "  #{label}: #{names.join(', ')}\n" unless names.empty?
          end

          # TODO - extensible blurbs for rails/newgem/adhearsion etc
          # e.g. for rails http://github.com/rails/rails/tree/daee6fd92ac16878f6806c3382a9e74592aa9656/railties/lib/rails_generator/scripts.rb#L50-74
          usage << <<-end_blurb

More are available at http://rubigen.rubyforge.org/
end_blurb

          usage << <<-end_blurb
Run generate with no arguments for usage information
     #{$0} test_unit

end_blurb
          return usage
        end
    end # Base

  end
end
