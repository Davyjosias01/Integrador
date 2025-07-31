require 'httparty'

class ObligationsController < ApplicationController
  def index
    if params[:commit].present?
      permitted = params.permit(
        :date_start, :date_end, :obligation, :fields,
        :integrated_at, :obligation_finished, :has_procuration, :commit
      )

      obligation = Obligation.new(ENV['RAZONET_TOKEN'])
      begin  
        response = obligation.get_obligation(permitted.to_h)
        if response.code == 200
          @companies = response.parsed_response["companies"] || []
        else
          puts "Código de resposta: #{response.code}"
        end
      rescue => e
        puts ""
        puts "Ocorreu um erro durante a requisição: #{e.message}"
        puts ""
      end
    end
  end

  def integrar
    puts params
  
  
  
  
  end


end