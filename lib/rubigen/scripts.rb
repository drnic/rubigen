require File.dirname(__FILE__) + '/options'

module RubiGen
  module Scripts

    # Generator scripts handle command-line invocation.  Each script
    # responds to an invoke! class method which handles option parsing
    # and generator invocation.
    class Base
      include Options
      default_options :collision => :ask, :quiet => false

      # Run the generator script.  Takes an array of unparsed arguments
      # and a hash of parsed arguments, takes the generator as an option
      # or first remaining argument, and invokes the requested command.
      def run(args = [], runtime_options = {})
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
        puts e
        puts "  #{e.backtrace.join("\n  ")}\n" if options[:backtrace]
        raise SystemExit
      end

      protected
        # Override with your own script usage banner.
        def banner
          "Usage: #{$0} generator [options] [args]"
        end

        def usage_message
          usage = "\nInstalled Generators\n"
          RubiGen::Base.sources.inject({}) do |mem, source|
            label = source.label.to_s.capitalize
            mem[label] ||= []
            mem[label] |= source.names(:visible)
            mem
          end.each_pair do |label, names|
            usage << "  #{label}: #{names.join(', ')}\n" unless names.empty?
          end

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
