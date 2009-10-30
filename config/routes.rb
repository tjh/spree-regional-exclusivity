# Put your extension routes here.

map.namespace :admin do |admin|
  admin.resources :products do |product|
    product.update_regional_ex_type 'update_regional_ex_type', :controller => 'product_regional_ex_type', :action => 'update_regional_ex_type'
    product.view_regional_ex_type   'view_regional_ex_type',   :controller => 'product_regional_ex_type', :action => 'show'
  end
  admin.resources :regional_ex_types
end  
