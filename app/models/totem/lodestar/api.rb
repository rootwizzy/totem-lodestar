module Totem
  module Lodestar
    class Api < ApplicationRecord

      extend FriendlyId
      friendly_id :title, use: [:slugged]
    end
  end
end
