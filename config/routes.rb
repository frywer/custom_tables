# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :custom_tables

resources :custom_tables do
  collection do
    get :context_menu
  end
end
resources :table_fields
resources :custom_entities do
  collection do
    get :bulk_edit
    post :bulk_update
    post :context_export
    get :context_menu
    delete :index, action: :destroy
  end
  member do
    get :add_belongs_to
    get :new_note
  end
end

resources :journals, only: [] do
  member do
    get 'edit_note'
  end
end