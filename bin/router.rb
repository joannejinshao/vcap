home = File.join(File.dirname(__FILE__), '../router')
ENV['BUNDLE_GEMFILE'] = "#{home}/Gemfile"
require File.join(home, 'lib/router')