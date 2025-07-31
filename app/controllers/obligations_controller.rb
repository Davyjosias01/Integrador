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
        puts "Ocorreu um erro durante a requisição: #{e.message}"
      end
    end
  end

  def integrar
    permitted = params.permit(
      :date_start, :date_end, :obligation, :note,
      :commit, :cnpj
    )
    
    obligation = Obligation.new(ENV['RAZONET_TOKEN'])

    begin
      response = obligation.integrate_obligation(permitted.to_h)
      
      if response.code == 200
        @companies = response.parsed_response["sucess"] || []
      else
        puts "Código da resposta: #{response.code}"
        puts "Mensagem: #{response.message}"
      end

    rescue => e
      puts "Ocorreu um erro na integração da obrigação: #{e.message}"
    end
    render :index
  end
end