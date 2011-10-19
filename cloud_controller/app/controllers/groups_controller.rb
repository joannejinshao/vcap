class GroupsController < ApplicationController
  before_filter :require_user
  before_filter :find_group_by_name, :except => [:create, :list]
  
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
  
  def list
    groups = user.groups
    result = Array.new
    groups.each do |group|
      result << {:name => group[:name], :sequence => group[:sequence]}
    end
     render :json => result
  end
  
  def get
    response = {
      :name => @group.name,
      :sequence =>@group.sequence
    }
    render :json => response.to_json
  end
  
  def delete     
    @group.destroy
    render :nothing => true, :status => 200
  end
  
  def remove_app
    #remove group binding
    appname = params[:appname]
    app = ::App.find_by_name(appname)   
    if app.group_binding
      app.group_binding.destroy
    end      
    @group.sequence = @group.sequence.gsub(/#{appname}:/, "")
    @group.save
    render :nothing => true, :status => 200
  end
  
  def find_group_by_name
    @group = Group.find_by_name(params[:name])
    raise CloudError.new(CloudError::GROUP_NOT_FOUND) unless @group  
  end  
end
