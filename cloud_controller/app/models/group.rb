class Group < ActiveRecord::Base
  has_many :group_bindings, :dependent => :destroy
  has_many :apps, :through => :group_bindings
end
