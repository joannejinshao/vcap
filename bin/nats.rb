BASE = File.dirname(__FILE__)
require File.join(BASE, 'vcap_lib.rb')


args = ARGV.dup
opts_parser = OptionParser.new do |opts|
  opts.on('--port PORT')                           { |port| $port = port.to_i }
  opts.on('--configdir CONFIGDIR', '-c CONFIGDIR') { |dir| $configdir = File.expand_path(dir.to_s) }
  opts.on('--config CONFIGDIR')                    { |dir| $configdir = File.expand_path(dir.to_s) }
  opts.on('--no-color', '--nocolor', '--nc')       { $nocolor = true }
  opts.on('--noprompt', '-n')                      { $noprompt = true }

end
args = opts_parser.parse!(args)

$nocolor = true unless STDOUT.tty?

if args.empty?
  STDERR.puts "Usage: #{$0} [start|stop|restart|tail|status] [COMPONENT] [--no-color] [--config CONFIGDIR]"
else
  command = args.shift.downcase
  if Run.respond_to?(command)
    Run.send(command)
  else
    STDERR.puts "Don't know what to do with #{command.inspect}"
  end
end