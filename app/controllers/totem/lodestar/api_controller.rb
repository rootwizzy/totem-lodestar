module Totem
  module Lodestar
    class ApiController < ApplicationController
      skip_before_action :verify_authenticity_token

      def index
      end

      def show
        p "\n\n Show: #{params.inspect} \n\n"
        if params[:file]
          file_path = Rails.public_path.join('/api/' + params[:api_id] + '/' + params[:file])
        else
          file_path = Rails.public_path.join('/api/' + params[:api_id] + '/index.html')
        end

        render file: file_path, layout: 'api'
      end
    end
  end
end


