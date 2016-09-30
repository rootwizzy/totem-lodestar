module Totem
  module Lodestar
    class Section < ApplicationRecord
      has_many :documents
      has_many :sections, foreign_key: :parent_id
      belongs_to :parent, class_name: "Section"
      belongs_to :version

      extend FriendlyId
      friendly_id :title, use: [:scoped], scope: [:version]
    end
  end
end
