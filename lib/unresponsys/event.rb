class Unresponsys
  class Event
    extend Forwardable
    delegate [:client] => :member
    attr_reader :member

    def initialize(options = {})
      @event_name = options[:event]
      @member     = options[:member]
      @properties = options[:properties]
    end

    def save
      build_body
      build_properties
      response = client.post("/events/#{@event_name}", body: @body.to_json)
      response.first['errorMessage'].blank?
    end

    private

    def build_body
      @body = {
        customEvent: {},
        recipientData: [{
          recipient: {
            listName: { objectName: @member.list.name },
            recipientId: @member.riid
          }
        }]
      }
    end

    def build_properties
      return unless @properties.present?
      @body[:recipientData].first[:optionalData] = []
      @properties.each_pair do |key, val|
        @body[:recipientData].first[:optionalData] << { name: key.to_s, value: val.to_s }
      end
    end
  end
end
