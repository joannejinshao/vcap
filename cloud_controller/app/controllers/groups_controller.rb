class GroupsController < ApplicationController
  def create
    name = body_params[:groupname]
    sequence = body_params[:appsequence]
    group = Group.find_by_name(name)
    
    if(!group)
      group = ::Group.new(:name => name, :sequence => sequence)
    else
      group.sequence = sequence
    end
    
    begin
      group.save!
    rescue => e
      raise e
    end
        
    render :json => {:result => 'success'}, :status => 302
  end
end
