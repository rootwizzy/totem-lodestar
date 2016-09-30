module Totem
  module Lodestar
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
