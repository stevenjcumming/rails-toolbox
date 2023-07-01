Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    if Rails.env.development?
      origins 'localhost:3000', 'localhost:3001', 'https://yourwebsite.com'
    else
      origins 'https://stage.yourwebsite.com', 'https://yourwebsite.com'
    end

    resource '*', 
      headers: :any, 
       methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end