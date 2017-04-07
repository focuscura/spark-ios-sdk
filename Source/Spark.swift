// Copyright 2016-2017 Cisco Systems Inc
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


import Foundation
import UIKit


/// *Spark* object is the entry point to use this Cisco Spark iOS SDK. A *Spark* object must be created with one of the following *AuthenticationStrategy*.
///
/// - *OAuthStrategy* - this should be used when *Spark* is to be authenticated as a registered Cisco Spark user.
///
/// ```` swift
///    let clientId = "Def123456..."
///    let clientSecret = "fed456..."
///    let scope = "spark:people_read spark:rooms_read spark:rooms_write spark:memberships_read spark:memberships_write spark:messages_read spark:messages_write"
///    let redirectUri = "MyCustomApplication://response"
///    let oauthStrategy = OAuthStrategy(clientId: clientId, clientSecret: clientSecret, scope: scope, redirectUri: redirectUri)
///    let spark = Spark(authenticationStrategy: oauthStrategy)
///    ...
///    if !oauthStrategy.authorized {
///      oauthStrategy.authorize(parentViewController: self) { success in
///        if !success {
///            print("User not authorized")
///        }
///      }
///    }
/// ````
///
/// - *JWTAuthStrategy* - this should be used when *Spark* is to be authenticated as a CIsco App ID.
///
/// ```` swift
///    let jwtAuthStrategy = JWTAuthStrategy()
///    let spark = Spark(authenticationStrategy: jwtAuthStrategy)
///    ...
///    if !jwtAuthStrategy.authorized {
///      jwtAuthStrategy.authorizedWith(jwt: myJwt)
///    }
/// ````
///
/// - attention: All APIs on Cisco Spark iOS SDK are expected to run on the application's main thread.
/// - since: 1.2.0
public class Spark {
    
    /// The version number of this Cisco Spark iOS SDK.
    public static let version = "1.2.0"
    
    /// Toggle to enable or disable console log output.
    ///
    /// - parameter enable: Set True to enable console log, False as not.
    /// - returns: Void
    public static func toggleConsoleLogger(_ enable: Bool) {
        LoggerManager.sharedInstance.toggleConsoleLogger(enable)
    }
    
    /// The *AuthenticationStrategy* object from the application when constructing *Spark*.
    /// It can be used to check and modify authentication state.
    public let authenticationStrategy: AuthenticationStrategy
    
    /// *Phone* represents a calling device in Cisco Spark iOS SDK. 
    /// It can be used to make media calls on Cisco Spark.
    public let phone: Phone
    
    /// CallNotificationCenter allows your application to be notified of call events
    public let callNotificationCenter: CallNotificationCenter
    
    public init(authenticationStrategy: AuthenticationStrategy) {
        self.authenticationStrategy = authenticationStrategy
        let deviceService = DeviceService(authenticationStrategy: authenticationStrategy)
        let callManager = CallManager(authenticationStrategy: authenticationStrategy, deviceService: deviceService)
        let webSocketService = WebSocketService(authenticationStrategy: authenticationStrategy, callManager: callManager)
        let applicationLifecycleObserver = ApplicationLifecycleObserver(webSocketService: webSocketService, callManager: callManager, deviceService: deviceService)
        phone = Phone(authenticationStrategy: authenticationStrategy, applicationLifecycleObserver: applicationLifecycleObserver, webSocketService: webSocketService, callManager: callManager, deviceService: deviceService)
        callNotificationCenter = callManager.callNotificationCenter
    }
    
    /// Rooms are virtual meeting places in Cisco Spark where people post messages and collaborate to get work done.
    /// Use *rooms* to manage the rooms on behalf of the authenticated user.
    ///
    /// - since: 1.2.0
    /// - see: Memberships API about how to manage people in a room.
    /// - see: Messages API about how post or otherwise manage the content in a room.
    public var rooms: RoomClient {
        return RoomClient(authenticationStrategy: authenticationStrategy)
    }
    
    /// People are registered users of Cisco Spark.
    /// Use *people*  to find a person on behalf of the authenticated user.
    ///
    /// - since: 1.2.0
    /// - see: Memberships API about how to manage people in a room.
    /// - see: Messages API about how post or otherwise manage the content in a room.
    public var people: PersonClient {
        return PersonClient(authenticationStrategy: authenticationStrategy)
    }
    
    /// Memberships represents a person's relationships to rooms.
    /// Use *membership*  to manage the authenticated user's relationship to rooms.
    ///
    /// - since: 1.2.0
    /// - see: Rooms API about how to manage rooms.
    /// - see: Messages API about how post or otherwise manage the content in a room.
    public var memberships: MembershipClient {
        return MembershipClient(authenticationStrategy: authenticationStrategy)
    }
    
    /// Messages are how we communicate in a room.
    /// Use *messages* to manage the messages on behalf of the authenticated user.
    ///
    /// - since: 1.2.0
    /// - see: Rooms API about how to manage rooms.
    /// - see: Memberships API about how to manage people in a room.
    public var messages: MessageClient {
        return MessageClient(authenticationStrategy: authenticationStrategy)
    }
    
    /// Webhooks allow the application to be notified via HTTP (or HTTPS?) when a specific event occurs in Cisco Spark,
    /// e.g. a new message is posted into a specific room.
    /// Use *Webhooks* to create and manage the webhooks for specific events.
    /// - since: 1.2.0
    public var webhooks: WebhookClient {
        return WebhookClient(authenticationStrategy: authenticationStrategy)
    }
    
    /// *Teams* are groups of people with a set of rooms that are visible to all members of that team.
    /// Use *teams* to create and manage the teams on behalf of the authenticated user.
    ///
    /// - since: 1.2.0
    /// - see: Team Memberships API about how to manage people in a team.
    /// - see: Memberships API about how to manage people in a room.
    public var teams: TeamClient {
        return TeamClient(authenticationStrategy: authenticationStrategy)
    }
    
    /// Team Memberships represent a person's relationships to teams.
    /// Use *teamMemberships* to create and manage the team membership on behalf of the authenticated user.
    ///
    /// - since: 1.2.0
    /// - see: Teams API about how to manage teams.
    /// - see: Rooms API about how to manage rooms.
    public var teamMemberships: TeamMembershipClient {
        return TeamMembershipClient(authenticationStrategy: authenticationStrategy)
    }
}
