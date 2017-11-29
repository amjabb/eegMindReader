var firebase = require("firebase")

var config = {
    apiKey: "AIzaSyA_0Xb1thilfPSL-4JjejGzMIXbVwKvjow",
    authDomain: "eegmindreader.firebaseapp.com",
    databaseURL: "https://eegmindreader.firebaseio.com",
    projectId: "eegmindreader",
    storageBucket: "eegmindreader.appspot.com",
    messagingSenderId: "224429570785"
  };
firebase.initializeApp(config);

var database = firebase.database();

updates = {};
updates['/training/trainingDone'] = 0
database.ref().update(updates)


setTimeout(callAfterTrainingDoneReset, 5000);

function callAfterTrainingDoneReset(){

    var updates = {};
    updates['/training/trainingStart'] = 1
    database.ref().update(updates)

    updates = {};
    updates['/training/trainingStart'] = 0
    database.ref().update(updates)

    updates = {};
    updates['/training/trainingOne'] = 1
    database.ref().update(updates)

    function callAfterTrainingTwo(){
        updates = {};
        updates['/training/trainingTwo'] = 0
        database.ref().update(updates)

        updates = {};
        updates['/training/trainingDone'] = 1
        database.ref().update(updates)

    }

    function callAfterTrainingOne(){
        updates = {};
        updates['/training/trainingOne'] = 0
        database.ref().update(updates)

        updates = {};
        updates['/training/trainingTwo'] = 1
        database.ref().update(updates)

        setTimeout(callAfterTrainingTwo, 20000);
    }

    setTimeout(callAfterTrainingOne, 20000);
}
