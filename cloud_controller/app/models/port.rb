class Port < ActiveRecord::Base
  belongs_to :app
  
  attr_accessor :destination
end
