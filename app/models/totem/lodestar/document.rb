module Totem
  module Lodestar
    class Document < ApplicationRecord

      belongs_to :version
      belongs_to :section

      extend FriendlyId
      friendly_id :title, use: [:scoped], scope: [:version, :section]

      def friendly_updated_at
        updated_at.to_formatted_s(:long).gsub(/[0-9][0-9]:[0-9][0-9]/, '')
      end
    end
  end
end
