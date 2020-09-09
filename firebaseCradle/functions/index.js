const functions = require('firebase-functions');

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);
exports.helloWorld = functions.database.ref('{id}/wetMode/value').onWrite((change,context) => {
     //const uid = change.data.ref.parent.once("value").then(snapshit => {
     //    return snapshit.val();
     //});
    const uid = context.params.id;
    console.log(uid);
    admin.database().ref(uid+'/wetMode/value').once('value', (snap) => {
        var shaw = snap.val();
        
        if (shaw == "1") {

            const payload = {
                notification: {
                    title: 'The bed is wet',
                    body: 'Please change the bed sheet',
                    badge: '1',
                    sound: 'default'
                },
            };
            var options = {
                priority: "high",
                timeToLive: 60 * 60 * 24
            };

            return admin.database().ref(uid+'/fcm-token').once('value').then(allToken => {
                if (allToken.val()) {
                    console.log('token available');
                    const token = Object.keys(allToken.val());
                    return admin.messaging().sendToDevice(token, payload, options);
                } else {
                    console.log('No token available');
                }
            });
        }


    });

});
