class HealthController < ApplicationController
  def index
    render json: { success: true }
  end
end