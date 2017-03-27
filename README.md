![TogetherStream](https://github.com/IBM-MIL/TogetherStream/blob/develop/iOS/TogetherStream/TogetherStream/Assets.xcassets/togetherstreamLogoStacked.imageset/togetherstreamLogoStacked@2x.png?raw=true)

## Summary
Together Stream allows you to stream content with others in real time. The stream host has full control to choose, pause, and skip any video in the queue — synchronizing playback immediately with participants’ devices.
### Features
- Create a shared video stream and invite Facebook friends
- Video playback is automatically synchronized between all stream participants
- Control the mood by updating the stream queue - Search or add popular videos from YouTube
- Chat with others about the current video, or suggest something different to be played next
- Invite others to Together Stream via Text or Email

Together Stream is powered by Contextual Sync and IBM Bluemix.

## Mininum requirements to run
[Xcode](https://developer.apple.com/download/) 8.2  
[CocoaPods](https://cocoapods.org/) 1.2.0  
[Carthage](https://github.com/Carthage/Carthage) 0.18.1

## Setup
### Download third party libraries
1. Clone the repo if you have not already done so.
2. Navigate to `iOS/TogetherStream` run `pod install` and `carthage update --platform iOS`

### YouTube Configuration
Together Stream uses YouTube videos as the source of content to be shared. To access the YouTube API you will need to generate and embed an API key.

1. Follow the instructions to create an API key here: https://developers.google.com/youtube/registering_an_application 
2. Add the key as `youtube_api_key` to the `private.plist` located at `iOS/TogetherStream/TogetherStream/Configuration`

### Facebook Configuration
Together Stream uses Facebook to authenticate users and to retrieve user information. To access the Facebook API you will need to create an app and link to it in the iOS application.

1. Follow steps to configure the Facebook App for iOS: https://developers.facebook.com/docs/ios/getting-started/
   **Note** You can skip installing the SDK since it was already installed above.
2. Add the Facebook app ID and secret to `backend/config/private/credentials.js`

### Apple Push Notification Configuration
Together Stream uses push notifications to send stream invites to users with the iOS app.

1. If not already, you will need to be enrolled in the [Apple Developer program](https://developer.apple.com/programs/)
2. Generate a push notification certificate and download the `.p12` file.
3. Go through these steps to generate a `cert.pem` and a `key.pem` https://github.com/node-apn/node-apn/wiki/Preparing-Certificates
4. Add these certificates to `backend/config/private/`

### Google Analytics Configuration
To keep track of analytics, generate a configuration file by following the instructions here: https://developers.google.com/analytics/devguides/collection/ios/v3/  
**Note** You can skip adding the Google Analytics SDK to the project since it was installed above.

*Skip Installation*  
You can skip installing Google Analytics by removing the method `setupGoogleAnalytics` in the `AppDelegate` and `sendGoogleAnalyticsEvent` in `Utilities/Utils.swift`

### Backend Configuration
1. In `backend/config/private/credentials.js` replace the `accessTokenKey` and `refreshTokenKey` with a unique string exactly **32 characters** long. This is used to encrypt the access tokens and refresh tokens in the database.
2. Replace the `sessionSecret` with a unique string. This is used to encrypt the session tokens.
3. Replace the email `userName` and `domainName` with your email address (i.e. `userName@domainName`), the `password` with your email password, and the `displayUserName` and `displayDomainName` with what you want the emails to be sent from. You can use the same values for here as your actual `userName` and `domainName` if you wish.

### Cloud Configuration
1. Go to https://console.ng.bluemix.net and create an account if you do not already have one.
2. Click "Create a Service", choose "Compose for PostgreSQL" and create it.
3. Do the same to create a "New Relic" service.
4. In your cloned repo, open `manifest.yml` and replace the services with the name of the services you created.
5. Make sure you have the [Cloud Foundry CLI](https://github.com/cloudfoundry/cli#downloads) installed.
6. Make sure you are logged in to your Bluemix account by running `cf login`
7. Deploy your app to bluemix with `cf push`
8. Add the server URL as `server_address` to `private.plist` located at `iOS/TogetherStream/TogetherStream/Configuration`

### Contexual Sync Configuration
1. Follow the instructions here to deploy a Contexual Sync container to blumix: https://github.com/csync/csync-server/wiki/Create-a-CSync-Instance-on-Bluemix  
Make sure that when you are creating your container, you add your Facebook credentials in this format:  
`
"CSYNC_FACEBOOK_ID=asfasfd",
"CSYNC_FACEBOOK_SECRET=asfdasdf"`
2. Add the public IP of the container as `csync_url` to the `private.plist` located at `iOS/TogetherStream/TogetherStream/Configuration`

## Local Configuration (Optional)
### Requirements
[npm](https://www.npmjs.com/) 4.1.2  
[node](https://nodejs.org/en/) 7.5

### Instructions
1. If the Xcode command line developer tools are not installed, run `xcode-select --install`
2. Navigate to your app on Bluemix and click on "Connections" in the left nav bar
3. Click on "View credentials" on the Compose for PostgreSQL service and copy those credentials to `backend/config/private/VCAP_SERVICES.json`
4. Navigate to `backend` and run `npm install`
5. Then run `npm start` to start the backend, take note of what port it is listening on
6. In the `private.plist` channel, change your server address to `http://localhost:<port number>`
7. Follow the instructions here to allow connections to a http address: http://stackoverflow.com/questions/31254725/transport-security-has-blocked-a-cleartext-http
8. If you would like to run your Contexual Sync server locally as well, follow the instructions here: https://github.com/csync/csync-server#local-deployment.  
Make sure you change the `private.plist` in the iOS app to the local Contextual Sync server.

## Disclaimer
Together Stream is intended solely for use with an Apple iOS product and intended to be used in conjunction with officially licensed Apple development tools and further customized and distributed under the terms and conditions of your licensed Apple Developer Program.

## Licenses
[iOS](LICENSE-IOS)  
[Non-iOS](LICENSE-NON-IOS)

## Contribution Guide
Want to contribute? Take a look at our [CONTRIBUTING.md](.github/CONTRIBUTING.md)
