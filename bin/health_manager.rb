home = File.join(File.dirname(__FILE__), '../health_manager')
ENV['BUNDLE_GEMFILE'] = "#{home}/Gemfile"
require File.join(home, 'lib/health_manager')