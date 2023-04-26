require 'digest'
require 'matrix'

require_relative '../helpers/openai'
# require_relative '../helpers/resemble'

class QuestionsController < ApplicationController
  def create
    unless params[:question].present?
      raise ActionController::ParameterMissing.new("Missing question parameter")
    end

    # Rails.logger.info pages_data
    result = formatted_embeds

    # resemble.create_clip(params[:question])

    # md5 = Digest::MD5.hexdigest params[:question]

    # Cache our results as requests come in.
    # answer = Rails.cache.fetch(md5, expires_in: 12.hours) do
    #   "this is an answer"
    # end

    # Rails.logger.info OpenaiHelper

    # embeds = OpenaiHelper.get_embeddings(params[:question])

    # Rails.logger.info embeds

    # vector1.inner_product(vector2) / (vector1.norm * vector2.norm)

    render json: { answer: "hello" }
  end
end