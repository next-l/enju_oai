Rails.application.routes.draw do
  get 'oai/provider' => 'oai#provider', as: 'oai_provider'
  get 'resourcesync/capabilitylist' => 'resourcesync#capabilitylist', as: 'capabilitylist'
  get 'resourcesync/resourcelist' => 'resourcesync#resourcelist', as: 'resourcelist'
  get 'resourcesync/changelist' => 'resourcesync#changelist', as: 'changelist'
  get 'resourcesync/resourcedump' => 'resourcesync#resourcedump', as: 'resourcedump'
end
