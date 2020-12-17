module Mavenlink
  class Client
    ENDPOINT = "https://api.mavenlink.com/api/v1/".freeze
    TIMEOUT = 180

    # @param settings [ActiveSuppport::HashWithIndifferentAccess]
    def initialize(settings = Mavenlink.default_settings)
      @settings = settings
      (@oauth_token = settings[:oauth_token]) || raise(ArgumentError, "OAuth token is not set")
      @endpoint = settings[:endpoint] || ENDPOINT
      @use_json = settings[:use_json]
      @user_agent_override = settings[:user_agent_override] if settings.key?(:user_agent_override)

      # TODO: implement with method_missing?
      # Declare API calls client.-->>workspaces<<---.create({})
      Mavenlink.specification.keys.each do |collection_name|
        singleton_class.instance_eval do
          define_method collection_name do
            ::Mavenlink::Request.new(collection_name, self)
          end
        end
      end
    end

    # @return [Faraday::Connection]
    def connection
      Faraday.new(connection_options) do |builder|
        if @use_json
          builder.headers["Content-Type"] = "application/json"
        else
          builder.use Faraday::Request::UrlEncoded
        end
        builder.adapter(*Mavenlink.adapter)
      end
    end

    # Performs custom GET request
    # @param [String] path
    # @param [Hash] arguments
    def get(path, arguments = {})
      Mavenlink.logger.note "Started GET /#{path} with #{arguments.inspect}"
      parse_request(connection.get(path, arguments).body)
    end

    # Performs custom POST request
    # @param [String] path
    # @param [Hash] arguments
    def post(path, arguments = {})
      Mavenlink.logger.note "Started POST /#{path} with #{arguments.inspect}"
      parse_request(connection.post(path, arguments).body)
    end

    # Performs custom PUT request
    # @param [String] path
    # @param [Hash] arguments
    def put(path, arguments = {})
      Mavenlink.logger.note "Started PUT /#{path} with #{arguments.inspect}"
      parse_request(connection.put(path, arguments).body)
    end

    # Performs custom PUT request
    # @param [String] path
    # @param [Hash] arguments
    def delete(path, arguments = {})
      Mavenlink.logger.note "Started DELETE /#{path} with #{arguments.inspect}"
      parse_request(connection.delete(path, arguments).body)
    end

    private

    attr_reader :oauth_token, :endpoint

    # @return [Hash]
    def connection_options
      user_agent = if @user_agent_override && @user_agent_override.length > 1
                     @user_agent_override.to_s
                   else
                     "Mavenlink Ruby Gem"
                   end
      {
        headers: { "Accept" => "application/json",
                   "User-Agent" => user_agent.to_s,
                   "Authorization" => "Bearer #{oauth_token}" },
        ssl: { verify: false },
        url: endpoint,
        request: { timeout: TIMEOUT }
      }.freeze
    end

    def parse_request(response)
      return unless response.present?

      parsed_response = JSON.parse(response)

      parsed_response.tap do
        Mavenlink.logger.whisper "Received response:"
        Mavenlink.logger.inspection response

        case parsed_response
        when Array
          Mavenlink.logger.whisper "Returned as a plain collection"
        when Hash
          if parsed_response["errors"]
            Mavenlink.logger.disappointment "REQUEST FAILED:"
            Mavenlink.logger.inspection parsed_response["errors"]
            raise InvalidRequestError, parsed_response
          end
        end
      end
    rescue JSON::ParserError => e
      raise Mavenlink::InvalidResponseError, e.message
    end
  end
end
