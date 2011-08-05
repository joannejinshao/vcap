class CustomServicesController < ApplicationController
  def list
    svcs = user.custom_services
    CloudController.logger.debug("Custom service listing found #{svcs.length} services.")

    ret = {}
    svcs.each do |svc|
      svc_type = svc.app.framework
      ret[svc_type] ||= {}
      ret[svc_type] = svc.app.name
      #ret[svc_type][svc.app.name] ||= {}
     # ret[svc_type][svc.name][svc.version] ||= {}
      #ret[svc_type][svc.name][svc.version] = svc.as_legacy
    end
    render :json => ret
  end 
  
end
