ActsAsApi::Config.accepted_api_formats << :mpac

ActionController::Renderers.add :mpac do |object, options|
  self.content_type ||= 'application/messagepack'
  self.response_body = MessagePack.pack(object)
end


module ActiveSupport
  class TimeWithZone
   def to_msgpack(out='')
     self.as_json.to_msgpack
   end
  end
end