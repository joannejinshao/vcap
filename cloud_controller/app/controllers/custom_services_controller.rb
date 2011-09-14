class CustomServicesController < ApplicationController
  def list
    svcs = Array.new
    apps = user.apps
    apps.each do |app|
      if(app.consumers&&app.consumers.size>0)
         svcs << app
      end
    end    
    CloudController.logger.debug("Custom service listing found #{svcs.length} services.")

    ret = {}
    svcs.each do |svc|
      svc_type = svc.framework
      ret[svc_type] ||= Array.new
      ret[svc_type] << svc.name
      #ret[svc_type][svc.app.name] ||= {}
     # ret[svc_type][svc.name][svc.version] ||= {}
      #ret[svc_type][svc.name][svc.version] = svc.as_legacy
    end
    render :json => ret
  end 
end
