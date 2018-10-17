Workarea::Admin::Engine.routes.draw do
  scope '(:locale)', constraints: Workarea::I18n.routes_constraint do
    resources :circuits, only: :index do
      member do
        post :enable
        post :disable
      end
    end
  end
end
