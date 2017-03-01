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
[XCode](https://developer.apple.com/download/) 8.2  
[CocoaPods](https://cocoapods.org/) 1.2.0  
[Carthage](https://github.com/Carthage/Carthage) 0.18.1

## Setup
### Download third party libraries
1. Clone the repo if you have not already done so.
3. Navigate to `iOS/TogetherStream` run `pod install` and `carthage update --platform iOS`
### YouTube Configuration
Together Stream uses YouTube videos as the source of content to be shared. To access the YouTube API you will need to generate and embed an API key.

1. Follow the instructions to create an API key here: https://developers.google.com/youtube/registering_an_application 
2. Add the key as `youtube_api_key` to the `private.plist` located at `iOS/TogetherStream/TogetherStream/Configuration`

### Facebook Configuration
Together Stream uses Facebook to authenticate users and to retrieve user information. To access the Facebook API you will need to create an app and link to it in the iOS application.

1. Follow steps to configure the Facebook App for iOS: https://developers.facebook.com/docs/ios/getting-started/
   *Note* You can skip installing the SDK since it was already installed above.

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


## Local Configuration
### Requirements
[npm](https://www.npmjs.com/) 4.1.2  
[node](https://nodejs.org/en/) 7.5

### Instructions
1. If the XCode command line developer tools are not installed, run `xcode-select --install`
2. Navigate to your app on Bluemix and click on "Connections" in the left nav bar
3. Click on "View credentials" on the Compose for PostgreSQL service and copy those credentials to `backend/config/private/VCAP_SERVICES.json`
4. Navigate to `backend` and run `npm install`
5. Then run `npm start` to start the backend, take note of what port it is listening on
6. In the `private.plist` channel, change your server address to `http://localhost:<port number>`
7. Follow the instructions here to allow connections to a http address: http://stackoverflow.com/questions/31254725/transport-security-has-blocked-a-cleartext-http
8. If you would like to run your Contexual Sync server locally as well, follow the instructions here: https://github.com/csync/csync-server#local-deployment. Make sure you change the `private.plist` to the local Contextual Sync server.

## Disclaimer
Legal stuff
