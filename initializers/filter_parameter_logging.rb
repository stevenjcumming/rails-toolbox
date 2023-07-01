
Rails.application.config.filter_parameters += [
  :passw, 
  :crypt, 
  :salt, 
  :certificate, 
  :ssn,
  :encrypted_token, 
  :trace,
  :jwt,
  :sentry_dsn,
  /token$/,
  /digest$/,
  /password/,
  /secret/,
  /key$/,
  /opt/
]