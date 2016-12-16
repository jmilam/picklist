Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'sill_fg/inv_update_from_qad', to: 'sill_fg#inv_update_from_qad'
  get 'sill_fg/sales_order_from_qad', to: 'sill_fg#sales_order_from_qad'
  post 'sill_fg/submit_trans', to: 'sill_fg#submit_trans'
  post 'sill_fg/change_status', to: 'sill_fg#change_status'
  get 'sill_fg/check_for_add_ons', to: 'sill_fg#check_for_add_ons'
  get 'sill_fg/get_date_specific_data', to: 'sill_fg#get_date_specific_data'
  post 'sill_fg/multi_complete', to: 'sill_fg#multi_complete'
  get 'sill_fg/get_completed_data_only', to: 'sill_fg#get_completed_data_only'

  get ':controller(/:action(/:id))'
  
  resources :sill_fg
  
end
