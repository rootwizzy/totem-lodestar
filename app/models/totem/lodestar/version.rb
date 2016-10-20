module Totem
  module Lodestar
    class Version < ApplicationRecord
      has_many :sections

      extend FriendlyId
      friendly_id :title, use: [:slugged]

      ## Override FriendlyId::Slugged to use '.' instead of '-'
      def normalize_friendly_id(string); string.upcase.gsub("-", ".") end
      def base_sections; self.sections.where(parent_id: nil) end

      def friendly_updated_at
        updated_at.to_formatted_s(:long).gsub(/[0-9][0-9]:[0-9][0-9]/, '')
      end
    end
  end
end
