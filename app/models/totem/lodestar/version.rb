module Totem
  module Lodestar
    class Version < ApplicationRecord
      has_many :sections

      extend FriendlyId
      friendly_id :title, use: [:slugged]

      ## Override FriendlyId::Slugged to use '.' instead of '-'
      def normalize_friendly_id(string)
        slug = string.upcase.gsub("-", ".")
      end

      def base_sections
        self.sections.where(parent_id: nil)
      end
    end
  end
end
