require 'httparty'

class Obligation
  include HTTParty
  base_uri 'https://app.razonet.com.br'

  def initialize(token)
    @headers={
      'Authorization' => token,
      'Content-type' => 'application/json'
    }
  end

  def get_obligation(params_hash)
    filter_parameters = filtered_and_cast_params(params_hash)
    begin
      self.class.get(
        '/integration/v1/companies/index', headers: @headers,
        query:{
          obligation: filter_parameters[:obligation],
          date_start: filter_parameters[:date_start],
          date_end: filter_parameters[:date_end],
          fields: "cnpj,#{filter_parameters[:fields]}",
          integrated_at: filter_parameters[:integrated_at],
          obligation_finished: filter_parameters[:obligation_finished],
          has_procuration: filter_parameters[:has_procuration]
        }
      )
      
    rescue => e
      Rails.logger.error("[Obligation#get_obligation] Error: #{e.class} - #{e.message}")
      OpenStruct.new(success?: false, error: e.message)
      
    end
  end

  def integrate_obligation(params_hash)
    filter_parameters = filtered_and_cast_params(params_hash)
    puts "parametros passados: #{filter_parameters}"
    begin
      self.class.post(
        '/integration/v1/companies/set_as_integrated', headers: @headers,
        query:{
          obligation: filter_parameters[:obligation],
          date_start: filter_parameters[:date_start],
          date_end: filter_parameters[:date_end],
          cnpj: filter_parameters[:cnpj],
          note: filter_parameters[:note]
        }    
      )
    rescue => e
      Rails.logger.error("[Obligation#integrate_obligation] Error: #{e.class} - #{e.message}")
      OpenStruct.new(success?: false, error: e.message)
    end
  end

  def filtered_and_cast_params(params_hash)
    filtred_params = params_hash.deep_dup.symbolize_keys #trabalhando com uma cópia de params, e não com um "ponteiro"
    filtred_params[:integrated_at] = filtred_params[:integrated_at].to_s == "1"
    filtred_params[:obligation_finished] = filtred_params[:obligation_finished].to_s == "1"
    filtred_params[:has_procuration] = filtred_params[:has_procuration].to_s == "1"
    return filtred_params
  end
end