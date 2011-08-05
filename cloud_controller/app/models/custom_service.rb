class CustomService < ActiveRecord::Base
  belongs_to :app
  belongs_to :user
  
  #When a custom service is deleted, how to deal with its consumer application?
  has_many :custom_service_bindings, :dependent => :destroy
end
