require 'digest'

class QuestionsController < ApplicationController
  def create
    unless params[:question].present?
      raise ActionController::ParameterMissing.new("Missing question parameter")
    end

    md5 = Digest::MD5.hexdigest params[:question]

    # Cache our results as requests come in.
    answer = Rails.cache.fetch(md5, expires_in: 12.hours) do
      "this is an answer"
    end

    Rails.logger.info "url: #{ENV['REDIS_URL']}"

    render json: { answer: answer }
  end
end