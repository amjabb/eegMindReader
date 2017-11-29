
// include modules
var firebase = require("firebase")
var spawn = require("child_process").spawn
var fs = require("fs")
var mv = require("mv")

// Firebase application info
var config = {
	apiKey: "AIzaSyA_0Xb1thilfPSL-4JjejGzMIXbVwKvjow",
	authDomain: "eegmindreader.firebaseapp.com",
	databaseURL: "https://eegmindreader.firebaseio.com",
	projectId: "eegmindreader",
	storageBucket: "eegmindreader.appspot.com",
	messagingSenderId: "224429570785"
};

// init the firebase
firebase.initializeApp(config)

var database = firebase.database()

// Global variables
var first_data = {}
var open_bci_process_start = {}
var model_generator_script = {}
var udp_client_classify = {}
var buffer= {}
var flag_process_one = false
var flag_process_two = false

function MoveAndFlushOutputFiles(outputFile, expectedOutputFile){
	
	// Moving outputfile to the expected output file
	mv(outputFile, expectedOutputFile, function(err){
		
		if(err){
			fs.writeFile(outputFile)
			MoveAndFlushOutputFiles(outputFile, expectedOutputFile)
			console.log("ERROR: Removing" + outputFile + " for " + expectedOutputFile +
			" .ERROR: " + err)
		}
		else{
			// Flushing outputFile  
			fs.truncate(outputFile, 0, function(){
				console.log("DONE truncating "+ outputFile +" to " + expectedOutputFile)
			})
		}
	})
	
}
function clearFile(fileName){
		fs.truncate(fileName, 0, function(){
			console.log("DONE clearing "+ fileName)
		})
}
database.ref("/training").on("value", function(snapshot){
	
	first_data = snapshot.val()
	
	// Check for trainingStart flag, will be giving this flag only at begining of trainingOne 
	// @note: before switching to trainingTwo set trainingStart = 0	in firebase
	if (first_data['trainingStart'] == 1)
	{
		open_bci_process_start = spawn("python", ["open_bci.py"])
	}
	
	// Check for trainingDone flag, if flag is true we are done collecting data, so kill py process
	if (first_data['trainingDone'] == 0)
	{
		// Check trainingOne flag true, process_one = true, ready to flush the output file   
		if(first_data['trainingOne'] == 1)
		{
			flag_process_one = true
			console.log("Setting flag_process_two to: " + flag_process_one)
			
		}
		// if flag_process_one is true, move output.csv to trainingOne.csv, clear output.csv
		else if (flag_process_one)
		{
			MoveAndFlushOutputFiles("output.csv", "trainingOne.csv")
			flag_process_one = false							
		}				
		
		
		// Check trainingTwo flag true, process_two = true, ready to flush the output file   
		if(first_data['trainingTwo'] == 1)
		{
			flag_process_two = true
			console.log("Setting flag_process_two to: " + flag_process_two)
		}
		// if flag_process_two is true, move output.csv to trainingTwo.csv, clear output.csv
		else if (flag_process_two)
		{
			MoveAndFlushOutputFiles("output.csv", "trainingTwo.csv")

			flag_process_one = false							
		}				

		else{
			console.log("IDLE_STATE: Not training any model. Plese check the training inputs.")
		}
	}
	else
	{ 
	 	console.log("TrainingDone is true...!!")
	 	// Training is done 
	 	// open_bci_process_start.kill("SIGKILL")
		
		// Start training the model... 
		model_generator_script = spawn("python", ["model_generator.py"])

		model_generator_script.on('exit', function(code, signal){
			console.log("HERE: ---" )
			// model has been created
			udp_client_classify = spawn("python", ["udp_client_classify.py"])
			console.log("AFTER: ---" )
			udp_client_classify.stdout.on('data', function(data){
				console.log("STDOUT: ---" )
				console.log("DATA >>>>" + data.toString())	
			})
			clearFile("trainingOne.csv")
			clearFile("trainingTwo.csv")
		})			
	}
	
	
})

database.ref("/appDone").on("value", function(snapshot){

	if(snapshot.val() == 1)
	{
		try{
			model_generator_script.kill("SIGKILL")
			open_bci_process_start.kill("SIGKILL")
		}
		catch(e){
			// pass
		}
		console.log("------------->>", snapshot.val())
	}
})




