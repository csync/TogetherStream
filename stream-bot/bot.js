//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-non-ios
//

'use strict';

let csync = require('csync');
let appVars = require('./config/appVars');
let isoDuration = require('iso8601-duration');

let botID = "122296268288083";
let clientWaitTime = 4000;

let streamPrefix = "streams.bot123";

let playlist = ['I_izvAbhExY','dQw4w9WgXcQ'];

let playlistIndex = 0;

let participants = [];

let app = csync({host: appVars.csyncServer, port: appVars.csyncPort, useSSL: false});

let bot = {};

let participantMonitor = require("./participantMonitor");

bot.run = function () {
    app.authenticate("demo", "demoToken(" + appVars.userToken + ")").then(function(authData){
        setup();
        streamPlaylist();
    }, function(error){
        console.error(error);
    });
};

let streamPlaylist = function () {
    let videoID = playlist[playlistIndex];
    fetchVideoInfo(videoID)
        .then(function (videoInfo) {
          incrementPlayIndex();
          let duration = videoInfo.items[0].contentDetails.duration;
          let secondsDuration = isoDuration.toSeconds(isoDuration.parse(duration));
          playVideo(videoID,secondsDuration);
        }, function (error) {
          console.error(error);
        });
};

let setup = function () {
    app.key(streamPrefix).write("");
    app.key(streamPrefix + ".heartbeat").write("",{acl: csync.acl.PublicReadCreate});
    app.key(streamPrefix + ".chat").write("",{acl: csync.acl.PublicReadCreate});
    app.key(streamPrefix + ".streamName").write("Stream Bot",{acl: csync.acl.PublicRead});
    app.key(streamPrefix + ".isActive").write("true",{acl: csync.acl.PublicRead});
    app.key(streamPrefix + ".isBuffering").write("true",{acl: csync.acl.PublicRead});
    app.key(streamPrefix + ".isPlaying").write("true",{acl: csync.acl.PublicRead});

    participantMonitor(app, streamPrefix);
    participantMonitor.didReceiveHeartbeats = function (heartBeats) {
        for(let participant in participants) {
            if(heartBeats.indexOf(participants[participant]) < 0) {
                let time = new Date().getTime() / 1000 - 978307200;
                let value = {id: "" + participants[participant], isJoining: "false", timestamp: "" + time};
                app.key(streamPrefix + ".participants").child().write(JSON.stringify(value),{acl: csync.acl.PublicRead})
            }
        }
        for(let heartbeat in heartBeats) {
            if(participants.indexOf(heartBeats[heartbeat]) < 0) {
                let time = new Date().getTime() / 1000 - 978307200;
                let value = {id: "" + heartBeats[heartbeat], isJoining: "true", timestamp: "" + time};
                app.key(streamPrefix + ".participants").child().write(JSON.stringify(value),{acl: csync.acl.PublicRead})
            }
        }
        participants = heartBeats
    }
};

let fetchVideoInfo = function (videoId) {
    return new Promise(function (resolve, reject) {
        let youtubeKey = appVars.youtubeKey;
        let requestString = "https://www.googleapis.com/youtube/v3/videos?key=" + youtubeKey +
            "&part=contentDetails,statistics&id=" + videoId;
        let request = require('request');
        request(requestString, function (error, response, body) {
            if (!error && response.statusCode == 200) {
                resolve(JSON.parse(body));
            }
            else {
                reject(error);
            }
        });
    });
};

let incrementPlayIndex = function () {
    playlistIndex++;
    if(playlistIndex >= playlist.length) {
        playlistIndex = 0;
    }
};

let playVideo = function (videoId, duration) {
    app.key(streamPrefix + ".currentVideoID").write(videoId,{acl: csync.acl.PublicRead});
    app.key(streamPrefix + ".playTime").write("0");
    setTimeout(function () {
        app.key(streamPrefix + ".isBuffering").write("false",{acl: csync.acl.PublicRead});
        let startTime = new Date().getTime();
        let finishTime = startTime + duration * 1000;
        let currentTime = startTime;
        let timer = setInterval(function () {
                let playTime = (currentTime - startTime) / 1000;
                app.key(streamPrefix + ".playTime").write("" + playTime, {acl: csync.acl.PublicRead});
                currentTime = new Date().getTime();
            if (currentTime >= finishTime) {
                clearInterval(timer);
                app.key(streamPrefix + ".isBuffering").write("true", {acl: csync.acl.PublicRead});
                streamPlaylist();
            }
        }, 200);
    }, clientWaitTime)
};

module.exports = bot;