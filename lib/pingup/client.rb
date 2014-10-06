module Pingup
  class Client
    attr_accessor :api_key, :api_secret, :sandbox

    def initialize(api_key, api_secret, sandbox=false)
      self.api_key = api_key
      self.api_secret = api_secret
      self.sandbox = sandbox
    end

    # resource is something like "places" or "places/2/services"
    def get(resource, params={})
      JSON.parse RestClient.get(build_resource_url(resource), {params: params, token: access_token})
    end

    # private

    def access_token
      if @auth_token && @auth_token['tokenExpiration']/1000.0 > Time.now.to_i+5
        return @auth_token["accessToken"] 
      else
        regenerate_token
      end
    end

    def regenerate_token
      response = RestClient.post("#{endpoint}/auth/generateTokens", {key: self.api_key, secret: self.api_secret})
      json = JSON.parse(response)
      @auth_token = json['token']
      @auth_token['accessToken']
    end

    def endpoint
      if self.sandbox
        "http://api.sandbox.pingup.com"
      else
        "https://api.pingup.com"
      end
    end

    def build_resource_url(resource)
      "#{endpoint}/v1/#{resource}"
    end
  end
end