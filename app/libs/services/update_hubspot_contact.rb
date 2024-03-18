module Services
  class UpdateHubspotContact
    require 'net/https'
    require 'uri'

    def initialize(user_id:)
      @user = User.find(user_id)
    end

    def perform
      contact_id = @user.hubspot_id || fetch_contact_id
      return unless contact_id
  
      update_uri = URI("https://api.hubapi.com/crm/v3/objects/contacts/#{contact_id}")
      properties = {
        properties: {
          lifecyclestage: lifecyclestage
        }
      }
      request = Net::HTTP::Patch.new(update_uri)
  
      response = send_request(update_uri, request, properties)
  
      if response.code == '200'
        Rails.logger.info("Hubspot: Contact updated successfully")
      else
        Rails.logger.error("Hubspot: Error while updating contact: #{response.body}")
      end
    end
  
    def lifecyclestage
      # evangelist == Offre(s) postée(s) 🎉
      # customer == Inscrtit(e)
      @user.internship_offers.any? ? 'evangelist' : 'customer'
    end
  
    def fetch_contact_id
      # search if contact exists
      uri = URI("https://api.hubapi.com/contacts/v1/contact/email/#{@user.email}/profile")
      request = Net::HTTP::Get.new(uri)
  
      response = send_request(uri, request)
  
      if response.code == '200'
        data = JSON.parse(response.body)
        contact_id = data['vid']
        puts "Contact trouvé: #{contact_id}"
        @user.update(hubspot_id: contact_id)
        contact_id
      else
        puts "Contact non trouvé"
        nil
      end
    end
  
    def send_request(uri, request, properties={})
      request = request
      request['Authorization'] = "Bearer #{ENV['HUBSPOT_TOKEN']}"
      request['Content-Type'] = 'application/json'
      request.body = properties.to_json
      request
  
      Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(request)
      end
    end
  end
end