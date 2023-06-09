const express = require("express");
const axios = require("axios");

const app = express();
app.use(express.json());

// List of cities and their corresponding coordinates in terms of the latitude and the longitude of the city
const cities = {
	Groningen: "53.219383 6.566502",
	Amsterdam: "52.370216 4.895168",
	Zwolle: "52.512791 6.091540",
	London: "51.509865 -0.118092",
	Bucharest: "44.426765 26.102537",
	Bern: "46.947975 7.447447",
};

// The port that will be used by the database server to listen to incoming messages
const dbPort = 8098;
// The address of the database's monitor
const monitorAddress = "http://localhost:8008";

let state = 1;

// Wait for POST requests on the root ('/') path
app.post("/", (req, res) => {
	// End the response first
	res.end();
	switch (state) {
		case 1:
			if (req.body.payload == "city") {
				// Client asked for a city, wait for the arrival of the string
				state = 2;
			} else {
				// Client asked to quit, terminate process
				process.exit(0);
			}
			break;
		case 2:
			if (req.body.payload in cities) {
				// Requested city is inside the database
                console.log("Requested city is inside the database");
				axios
					.post(monitorAddress, {
						sender: "d",
						receiver: "c",
						payload: "coordinates",
					})
					.catch((_) => {
						console.log(`Error occurred when communicating with the monitor`);
						// Communication with the monitor cannot happen. Quit the process.
						process.exit(-1);
					})
					.then((_) => {
						// Send the coordinates of the given city
						axios
							.post(monitorAddress, {
								sender: "d",
								receiver: "c",
								payload: cities[req.body.payload],
							})
							.catch((_) => {
								console.log(
									`Error occurred when communicating with the monitor`
								);
								// Communication with the monitor cannot happen. Quit the process.
								process.exit(-1);
							});
					});
			} else {
				// Requested city is not in the database
                console.log("Requested city is not inside the database");
				axios
					.post(monitorAddress, {
						sender: "d",
						receiver: "c",
						payload: "missingCity",
					})
					.catch((_) => {
						console.log(`Error occurred when communicating with the monitor`);
						// Communication with the monitor cannot happen. Quit the process.
						process.exit(-1);
					});
			}
			state = 1;
			break;
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
});

// Start the database server
app.listen(dbPort, () => {
	console.log(`Database listening on ${dbPort}`);
});
