home = File.join(File.dirname(__FILE__), '../dea')
ENV['BUNDLE_GEMFILE'] = "#{home}/Gemfile"
require File.join(home, 'lib/dea')