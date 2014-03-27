require 'prixfixe'
require 'rails'
module MyPlugin
  class Railtie < Rails::Railtie
    railtie_name :prixfixe

    rake_tasks do
      load "tasks/prixfixe.rake"
    end
  end
end
