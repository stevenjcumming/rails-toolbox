Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :products, only: %i[index show create update destroy]
      resources :products, except: [:create] # prefer not use use unless only one
      resources :products, param: :reference_id
      resources :tags, only: %i[index show], param: :slug
      resource :me, only: %i[show], controller: 'me'
      resources :photos, controller: 'images'
      resources :user_permissions, controller: 'admin/user_permissions' # Admin::UserPermissions
      patch '/messages/read/:connection_id', to: 'messages#read', as: 'messages_read'
      get 'products/:id', to: 'products#show'
      resource :username_availability, only: %i[show], controller: 'username_availability'
      resources :users, only: %i[show], param: :username
      resources :photos, path_names: { new: 'make', edit: 'change' }

    end
  end

  # route /articles (without the prefix /admin) to Admin::ArticlesController
  scope module: 'admin' do
    resources :articles, :comments
  end
  # or resources :articles, module: 'admin'
 
  # route /admin/articles to ArticlesController (without the Admin:: module prefix)
  scope '/admin' do
    resources :articles, :comments
  end
  # or resources :articles, path: '/admin/articles'

  # nested resources
  resources :magazines do
    resources :ads
  end
  # => /magazines/:magazine_id/ads/:id	


  # default 
  #You cannot override defaults via query parameters - this is for security reasons.
  defaults format: :json do
    resources :photos
  end

  # /exit
  get 'exit', to: 'sessions#destroy', as: :logout

  # segment constraints
  get 'photos/:id', to: 'photos#show', id: /[A-Z]\d{5}/

  # request-based constraints
  get 'photos', to: 'photos#index', constraints: { subdomain: 'admin' }
  # or
  namespace :admin do
    constraints subdomain: 'admin' do # always use a string for the subdomain
      resources :photos
    end
  end

  # glob => params[:other] to "12" or "long/path/to/12"
  get 'photos/*other', to: 'photos#unknown'
  # params[:section]
  get 'books/*section/:title', to: 'books#show'

  


  # RestrictedListConstraint is at the bottom of the file
  get '*path', to: 'restricted_list#index', constraints: RestrictedListConstraint.new

  constraints(RestrictedListConstraint.new) do
    get '*path', to: 'restricted_list#index'
    get '*other-path', to: 'other_restricted_list#index'
  end
end


# you can put this at the top of the file in real life
class RestrictedListConstraint
  def initialize
    @ips = RestrictedList.retrieve_ips
  end

  def matches?(request)
    @ips.include?(request.remote_ip)
  end
end

