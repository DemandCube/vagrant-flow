require 'optparse'

module VagrantPlugins
  module CommandVagrantFlow
    module Command
      class Root < Vagrant.plugin("2", :command)
        def self.synopsis
          "manages vagrantflow"
        end

        def initialize(argv, env)
          super

          @main_args, @sub_command, @sub_args = split_main_and_subcommand(argv)

          @subcommands = Vagrant::Registry.new
          @subcommands.register(:ansibleinventory) do
            require_relative "ansibleinventory"
            AnsibleInventory
          end
          
          @subcommands.register(:multiinit) do
            require_relative "multiinit"
            MultiInit
          end
          
          @subcommands.register(:hostfile) do
            require_relative "hostfile"
            HostFile
          end
          
          @subcommands.register(:playbook) do
            require_relative "playbook"
            Playbook
          end
          
          @subcommands.register(:multicommand) do
            require_relative "multicommand"
            MultiCommand
          end

          @subcommands.register(:installdotoken) do
            require_relative "installdotoken"
            InstallDOToken
          end
          
        end

        def execute
          if @main_args.include?("-h") || @main_args.include?("--help")
            # Print the help for all the sub-commands.
            return help
          end

          # If we reached this far then we must have a subcommand. If not,
          # then we also just print the help and exit.
          command_class = @subcommands.get(@sub_command.to_sym) if @sub_command
          return help if !command_class || !@sub_command
          @logger.debug("Invoking command class: #{command_class} #{@sub_args.inspect}")

          # Initialize and execute the command class
          command_class.new(@sub_args, @env).execute
        end

        # Prints the help out for this command
        def help
          opts = OptionParser.new do |o|
            o.banner = "Usage: vagrant flow <command> [<args>]"
            o.separator ""
            o.separator "Available subcommands: ansibleinventory,"

            # Add the available subcommands as separators in order to print them
            # out as well.
            keys = []
            @subcommands.each { |key, value| keys << key.to_s }

            keys.sort.each do |key|
              o.separator "     #{key}"
            end

            o.separator ""
            o.separator "For help on any individual command run `vagrant flow COMMAND -h`"
          end

          @env.ui.info(opts.help, :prefix => false)
        end
      end
    end
  end
end
