require 'nokogiri'
require 'faraday'
require 'ostruct'

class NasaApodScraperError < StandardError; end

class NasaApodScraper
  BASE_URL = 'https://apod.nasa.gov/apod'
  MIN_DATE = Date.new(1996, 1, 1)
  MAX_DATE = Date.today

  def self.fetch_apod(date)
    unless date.between?(MIN_DATE, MAX_DATE)
      raise NasaApodScraperError, 
            "Data inválida. Insira uma data entre #{MIN_DATE.strftime('%d/%m/%Y')} e #{MAX_DATE.strftime('%d/%m/%Y')}."
    end

    formatted_date = date.strftime('%y%m%d')
    url = "#{BASE_URL}/ap#{formatted_date}.html"

    begin
      response = Faraday.get(url)
      
      if response.success?
        doc = Nokogiri::HTML(response.body)
        title = doc.css('center b').first&.text
        image_path = doc.css('img').first&.attributes['src']&.value
        full_image_url = image_path ? "#{BASE_URL}/#{image_path}" : nil
        explanation = doc.css('p').max_by { |p| p.text.split.size }&.text

        OpenStruct.new(
          title: title,
          image_url: full_image_url,
          explanation: explanation,
          original_url: url
        )
      else
        raise NasaApodScraperError, 'Data não encontrada no site da NASA'
      end
    rescue Faraday::Error => e
      Rails.logger.error "APOD Fetch Error: #{e.message}"
      raise NasaApodScraperError, 'Erro ao se conectar ao site da NASA'
    end
  end
end
