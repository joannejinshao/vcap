class GroupsController < ApplicationController
  def create
    name = body_params[:name]
    group = ::Group.new(:name => name)
    begin
      group.save!
    rescue => e
      raise e
    end
  end
end
