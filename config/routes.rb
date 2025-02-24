# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :menu_items, only: %i[index show]
      resources :footer_items, only: %i[index show]
      resources :pages, only: %i[index show]
      resources :sections, only: %i[index show]
      resources :columns, only: %i[index show]
      resources :blog_posts
      resources :post_comments
      resources :image_files

      post 'validate_html', to: 'validations#validate_html'
    end
  end

  devise_for :users, controllers: {
    sessions: "users/sessions"
  }

  devise_scope :user do
    get "/users/sign_out", to: "devise/sessions#destroy"
  end

  namespace :admin do
    root "dashboard#index" # Admin dashboard
    resources :blog_posts, except: [ :destroy ]
    delete "/blog_posts/:id", to: "blog_posts#destroy", as: "delete_blog_post"
    get "/blog_posts/:id/delete", to: "blog_posts#destroy", as: "destroy_blog_post"
    resources :columns, except: [ :destroy ]
    delete "/columns/:id", to: "columns#destroy", as: "delete_column"
    get "/columns/:id/delete", to: "columns#destroy", as: "destroy_column"
    resources :sections, except: [ :destroy ]
    delete "/sections/:id", to: "sections#destroy", as: "delete_section"
    get "/sections/:id/delete", to: "sections#destroy", as: "destroy_section"
    get "/page/new_column/:id", to: "sections#add_column_to_section", as: "add_column_to_existing_section"
    get "/page/new_column", to: "sections#add_column_to_section", as: "add_column_to_new_section"
    resources :pages, except: [ :destroy ]
    delete "/pages/:id", to: "pages#destroy", as: "delete_page"
    get "/pages/:id/delete", to: "pages#destroy", as: "destroy_page"
    get "/page/new_section/:id", to: "pages#add_section_to_page", as: "add_section_to_existing_page"
    get "/page/new_section", to: "pages#add_section_to_page", as: "add_section_to_new_page"
    resources :users, except: [ :destroy ]
    delete "/users/:id", to: "users#destroy", as: "delete_user"
    get "/users/:id/delete", to: "users#destroy", as: "destroy_user"
    resources :image_files, except: [ :destroy ]
    delete "/image_files/:id", to: "image_files#destroy", as: "delete_image_file"
    get "/image_files/:id/delete", to: "image_files#destroy", as: "destroy_image_file"
    resources :menu_items, except: [ :destroy ]
    delete "/menu_items/:id", to: "menu_items#destroy", as: "delete_menu_item"
    get "/menu_items/:id/delete", to: "menu_items#destroy", as: "destroy_menu_item"
    resources :footer_items, except: [ :destroy ]
    delete "/footer_items/:id", to: "footer_items#destroy", as: "delete_footer_item"
    get "/footer_items/:id/delete", to: "footer_items#destroy", as: "destroy_footer_item"
    resources :site_setups, except: [ :destroy ]
    delete "/site_setups/:id", to: "site_setups#destroy", as: "delete_site_setup"
    get "/site_setups/:id/delete", to: "site_setups#destroy", as: "destroy_site_setup"
  end

  resources :blogs
  resources :contacts, only: [ :new, :create, :show ]
  resources :image_files, only: [ :show ]
  resources :section, only: [ :index ]
  resources :columns, only: [ :index ]
  resources :search, only: [ :new ]

  get "professional", to: "pages#show", defaults: { id: "overview" }, as: :professional_page

  # Dynamic route for pages
  get "/:id", to: "pages#show", as: :page

  root "home#index"
end
