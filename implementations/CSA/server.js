const express = require("express");
const axios = require("axios");

const app = express();
app.use(express.json());

// The port that will be used by the server to listen to incoming messages
const serverPort = 8081;
// The address of the server's monitor
const monitorAddress = "http://localhost:8001";
// Whether the initial action has been taken or not
let actionTaken = false;

// Initial state of the server
let state = 1;

// Wait for POST requests on the root ('/') path
app.post("/", (req, res) => {
	res.end();
	if (state == 1) {
		// In this state the server receives the auth label from the authorization server
		state = 2;
	} else {
		// In this state the server receives the boolean from the authorization server denoting whether the
		// client is authorized or not
		if (req.body.payload) {
			console.log("Client authorized!");
			// Send the quit label to the client, authorization successful
			axios
				.post(monitorAddress, {
					sender: "s",
					receiver: "c",
					payload: "quit",
				})
				.catch((_) => {
					console.log(`Error occurred when communicating with the monitor`);
					// Communication with the monitor cannot happen. Quit the process.
					process.exit(-1);
				})
				.then(() => {
					process.exit(0);
				});
		} else {
			console.log("Authorization denied!");
			// Retry the authorization
			axios
				.post(monitorAddress, {
					sender: "s",
					receiver: "c",
					payload: "login",
				})
				.catch((_) => {
					console.log(`Error occurred when communicating with the monitor`);
					// Communication with the monitor cannot happen. Quit the process.
					process.exit(-1);
				});
		}
		state = 1;
	}
});

// Protocol violation handler
app.post("/api/violation", (req, res) => {
    res.end();
    console.log("PROTOCOL VIOLATION");
    process.exit(-1);
});

// Respond with an empty object to signal that the party is online
app.get("/api/alive", (req, res) => {
	res.end();
});

// Party can commence the transmission
app.post("/api/alive", (req, res) => {
	res.end();
	if (!actionTaken) {
		actionTaken = true;
		// Send the login label initially to the client
		axios
			.post(monitorAddress, {
				sender: "s",
				receiver: "c",
				payload: "login",
			})
			.catch((err) => {
				console.log(`Error occurred when communicating with the monitor`);
				// Communication with the monitor cannot happen. Quit the process.
				process.exit(-1);
			});
	}
});

// Start the server
app.listen(serverPort, () => {
	console.log(`Server listening on ${serverPort}`);
});
