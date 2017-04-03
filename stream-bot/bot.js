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

let playlist = ["L_jWHffIx5E", "fJ9rUzIMcZQ", "9jK-NcRmVcw", "oRdxUFDoQe0", "I_izvAbhExY", "pIgZ7gMze7A", "wCDIYvFmgW8", "dTAAsCNK7RA", "dQw4w9WgXcQ", "jofNR_WkoCE", "aaqzPMOd_1g", "QiOF6KfXt7k", "TwyPsUd9LAk", "7exajMfNiFQ", "e5xSHuO0dJI", "PnCVZozHTG8", "JNsKvZo6MDs", "a1Y73sPHKxw", "J---aiyznGQ", "V_OVxxIvqVw", "epUk3T2Kfno", "NHozn0YXAeE", "gJLIiF15wjQ", "2DiQUX11YaY", "TcWPiHjIExA", "AQXVHITd1N4", "r2pt2-F2j2g", "WDZJPJV__bQ", "y6Sxv-sUYtM", "QH2-TGUlwu4", "dMH0bHeiRNg", "EwTZ2xpQwpA", "9EcjWd-O4jI", "C-u5WLJ9Yk4", "9bZkp7q19f0", "5NPBIwQyPWE", "lvBOZCrJsAI", "0n4f-VDjOBE", "txqiwrbYGrs", "68ugkg9RePc", "UPXUG8q4jKU", "8WEtxJ4-sh4", "ZZ5LpwO-An4", "rg6CiPI6h2g", "sNypbmPPDco", "2Z4m4lnjxkY", "lLXaRtc1f4I", "aEryAoLfnAA", "7ZS2-4-iUJ4", "fWNaR-rxAic", "kfVsfOSbJY0", "3RSCSw_VwIs", "Ct6BUPvE2sM", "Eo-KmOd3i7s", "IvUU8joBb1Q", "oobaEVt31nA", "EX1gM7bXfVU", "uU6U-8LP1DY", "1nCqRmx3Dnw", "djV11Xbc914", "ZYPEE57Z_Ug", "N2_HkWs7OM0", "Fe93CLbHjxQ", "uRv8gnBMiWM", "siwpn14IE7E", "7T2oje4cYxw", "F3qvosHHcWc", "shbgRyColvE", "FTQbiNvZqaY", "PWgvGjAhvIw", "PfYnvDL0Qcw", "xWIKQMBBTtk", "xFrGuyw1V8s", "DsuVLsDyln4", "hMnk7lh9M3o", "0M7ibPk37_U", "ol1wxsN411k", "4WgT9gy4zQA", "JcniyQYFU6M", "CQzUsTFqtW0", "S9Iq6LA7sZI", "agi4geKb8v8", "Tx1XIm6q4r4", "EQ1HKCYJM5U", "ndnjBq8ROpo", "8nHnQQhWQVA", "Awf45u6zrP0", "YOnYOHQeW_I"];

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
        shufflePlaylist();
        playlistIndex = 0;
    }
};

// Fisher-Yates Shuffle adopted from http://stackoverflow.com/a/6274398/3980472
let shufflePlaylist = function () {
  let counter = playlist.length;
  while(counter > 0) {
      let index = Math.floor(Math.random() * counter);
      counter--;

      let temp = playlist[counter];
      playlist[counter] = playlist[index];
      playlist[index] = temp;
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