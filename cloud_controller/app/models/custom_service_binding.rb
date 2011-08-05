class CustomServiceBinding < ActiveRecord::Base
  belongs_to :app
  belongs_to :custom_service
  belongs_to :user
end
