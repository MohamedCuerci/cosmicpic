class ApodsController < ApplicationController
  def index
    @apod = nil
  end

  def search
    begin
      if params[:date].blank?
        flash[:alert] = "Você precisa inserir uma data para buscar informações."
        redirect_to root_path
      else
        date = Date.parse(params[:date])
        @apod = NasaApodScraper.fetch_apod(date)
        
        if @apod
          render :result
        else
          flash.now[:alert] = "No image found for this date"
          render :index
        end
      end
    rescue NasaApodScraperError => e
      flash.now[:alert] = e.message
      render :index
    end
  end
end
