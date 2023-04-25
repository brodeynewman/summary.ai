require 'digest'

class QuestionsController < ApplicationController
  def create
    unless params[:question].present?
      raise ActionController::ParameterMissing.new("Missing question parameter")
    end

    md5 = Digest::MD5.hexdigest params[:question]

    answer = Rails.cache.fetch(md5, expires_in: 1.hour) do
      "this is an answer"
    end

    render json: { answer: answer }
  end
end