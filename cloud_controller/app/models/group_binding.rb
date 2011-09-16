class GroupBinding < ActiveRecord::Base
  belongs_to :app
  belongs_to :group
end
