class AppDependency < ActiveRecord::Base 
  belongs_to :consumer, :class_name => "App"
  belongs_to :provider, :class_name => "App"
end


 
