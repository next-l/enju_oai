Rails.application.routes.draw do
  get 'oai/provider' => 'oai#provider', as: 'oai_provider'
end
