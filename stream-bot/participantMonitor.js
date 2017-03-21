/**
 * Created by danielfirsht on 3/21/17.
 */

let streamHeartbeats = {};

let checkPulseInterval = 1;
let heartbeatExpiredInterval = 10;

let participantMonitor = function (app, streamPrefix) {
    app.key(streamPrefix + ".heartbeat.*").listen(function(error, value) {
        if (error) {
            console.error(error)
        } else {
            let userId = value.key.split(".").pop();
            if (value.exists) {
                streamHeartbeats[userId] = value.data
            }
            else {
                delete streamHeartbeats[userId]
            }
        }
    });

    setInterval(function () {
        let currentTime = new Date().getTime();
        // Divide by 1000 to convert to seconds and subtract constant to convert time to be from 00:00:00 UTC on 1 January 2001
        currentTime = currentTime / 1000 - 978307200;
        for(var userId in streamHeartbeats) {
            if(streamHeartbeats.hasOwnProperty(userId)) {
                if(currentTime - streamHeartbeats[userId] > heartbeatExpiredInterval) {
                    delete streamHeartbeats[userId];
                }
            }
        }
        participantMonitor.didReceiveHeartbeats(Object.keys(streamHeartbeats));
    }, checkPulseInterval)
};

module.exports = participantMonitor;