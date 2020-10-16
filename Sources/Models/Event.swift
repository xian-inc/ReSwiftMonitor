
class JSONStringConvertible<U:Encodable>{
    func toJSONString()->String?{
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(self) {
            return String(data:data, encoding:.utf )
        }
        return nil
    }
}

class EmitEvent: JSONStringConvertible {
    var event: String!
    var data: AnyObject?
    var cid: Int!

    required init() {}

    init(event: String, data: AnyObject?, cid: Int) {
        self.event = event
        self.data = data
        self.cid = cid
    }
}

class ReceiveEvent: JSONStringConvertible {
    var data: AnyObject?
    var error: AnyObject?
    var rid: Int!

    convenience init(data: AnyObject? , error: AnyObject?, rid: Int) {
        self.init()
        self.data = data
        self.error = error
        self.rid = rid
    }

    required init() {}
}

class Channel: JSONStringConvertible{
    var channel: String!
    var data: AnyObject?

    init(channel: String, data: AnyObject?) {
        self.channel = channel
        self.data = data
    }

    required init() {}
}

class AuthData: JSONStringConvertible{
    var authToken: String?
    init(authToken: String?) {
        self.authToken = authToken
    }
    required init() {}
}

class HandShake: JSONStringConvertible {
    var event: String!
    var data: AuthData!
    var cid: Int!

    init(event: String, data: AuthData, cid: Int) {
        self.event = event
        self.data = data
        self.cid = cid
    }

    required init() {}
}

class Model {
    public static func getEmitEventObject(eventName: String, data: AnyObject?, messageId: Int) -> EmitEvent {
        return EmitEvent(event: eventName, data: data, cid: messageId)
    }

    public static func getReceiveEventObject(data: AnyObject?, error: AnyObject?, messageId: Int) -> ReceiveEvent {
        return ReceiveEvent(data: data, error: error, rid: messageId)
    }

    public static func getChannelObject(data: AnyObject?) -> Channel? {
        if let channel = data as? [String: Any] {
            return Channel(channel: channel["channel"] as! String, data: channel["data"] as AnyObject)
        }
        return nil
    }

    public static func getSubscribeEventObject(channelName: String, messageId: Int) -> EmitEvent {
        return EmitEvent(event: "#subscribe", data: Channel(channel: channelName, data: nil) as AnyObject, cid: messageId)
    }

    public static func getUnsubscribeEventObject(channelName: String, messageId: Int) -> EmitEvent {
        return EmitEvent(event: "#unsubscribe", data: Channel(channel: channelName, data: nil) as AnyObject, cid: messageId)
    }

    public static func getPublishEventObject(channelName: String, data: AnyObject?, messageId: Int) -> EmitEvent {
        return EmitEvent(event: "#publish", data: Channel(channel: channelName, data: data) as AnyObject, cid: messageId)
    }

    public static func getHandshakeObject(authToken: String?, messageId: Int) -> HandShake {
        return HandShake(event: "#handshake", data: AuthData(authToken: authToken), cid: messageId)
    }

}
