module Totem
  module Lodestar
    class Document < ApplicationRecord
      belongs_to :version
      belongs_to :section

      extend FriendlyId
      friendly_id :title, use: [:scoped], scope: [:version, :section]
    end
  end
end
