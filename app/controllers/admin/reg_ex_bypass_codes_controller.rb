class Admin::RegExBypassCodesController < Admin::BaseController
  resource_controller
  helper 'spree/base'
  
  new_action.wants.html do
    RegExBypassCode.create!
    redirect_to :action => 'index'
  end
  
  index.before { RegExBypassCode.purge_stale_codes }
end