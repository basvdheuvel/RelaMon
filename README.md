# RelaMon

RelaMon is a JS toolkit for the runtime verification of web applications written in any language.
The toolkit is based on formal frameworks for verifying the correctness of models of multiparty communication protocols.

Protocols and participant settings are configures using JSON.
The role's of the participants can be implemented in any language that can talk over HTTP.
This repository contains example implementations of two protocols, written in JS; they are included in `implementations/`.

Additionally, this toolkit contains an orthogonal Rascal project for transpiling multiparty protocols written as global types.
For the purposes of this repository, the Rascal tool transpiles global types to the JSON configurations mentioned above.
This repository contains several example global types; they are included in `global-types/`.

This repository contains instructions on how to run the toolkit using Docker, as well as instructions on how to setup and run the toolkit without Docker.

This tool was originally developed as part of the Bachelor's project of Rares Dobre at the University of Groningen in The Netherlands.
The supervisors were: Bas van den Heuvel, Jorge A. Pérez.

## Run using Docker

To get started, make sure you have a copy of Docker installed.
Though Linux is recommended, Docker also works on Windows and MacOS.
Please follow [these instructions](https://docs.docker.com/get-docker/) to install Docker on your system of choice.

After installing Docker, open a terminal and pull our Docker image:
```
docker pull basvdheuvel/relamon
```
Before using any of our tools, run our image as a Docker session:
```
docker run --rm -d -it --name relamon-session basvdheuvel/relamon
```
The flag `--rm` automatically removes the session once it exits (e.g., upon an error), `-d` runs the session in the background, `-it` makes sure STDIN is open and allocates a pseudo-TTY (for command line interaction).

### Running protocol implementations

To run a participant implementation or monitor, use the following command:
```
docker exec -it relamon-session ./run.sh [DIR] [PARTICIPANT] [impl|mon]
```
The argument `[DIR]` specifies the directory under which the protocol's JSON configurations and participant JS implementations reside.
The argument `[PARTICIPANT]` specifies the participant for which you will be running the implementation or monitor.
Finally, `impl` specifies to run the implementation, and `mon` to run the monitor.

For every participant, first run the implementation and then the monitor.
In reverse order, the tool will not work.

#### Example: running the authorization protocol

Run the following commands, in order, and each in a separate terminal.
Then, follow the prompts in each terminal.
```
docker exec -it relamon-session ./run.sh CSA client impl
docker exec -it relamon-session ./run.sh CSA client mon
docker exec -it relamon-session ./run.sh CSA server impl
docker exec -it relamon-session ./run.sh CSA server mon
docker exec -it relamon-session ./run.sh CSA authorization impl
docker exec -it relamon-session ./run.sh CSA authorization mon
```
*Hint: the password is `secretPassword`!*

#### Example: running the third-party weather API protocol

Run the following commands, in order, and each in a separate terminal.
Then, follow the prompts in each terminal.
```
docker exec -it relamon-session ./run.sh Weather client impl
docker exec -it relamon-session ./run.sh Weather client mon
docker exec -it relamon-session ./run.sh Weather db impl
docker exec -it relamon-session ./run.sh Weather db mon
docker exec -it relamon-session ./run.sh Weather weatherwrapper impl
docker exec -it relamon-session ./run.sh Weather weatherwrapper mon
```
*Note: the weather API requires an API key.*
To obtain one, register at [openweathermap.org](https://openweathermap.org), then generate an API key [here](https://home.openweathermap.org/api_keys).

*Hint: the city database knows coordinates for Groningen, Amsterdam, Zwolle, London, Bucharest, and Bern.*

### Running the Rascal transpiler

Run the following command for each participant of a global type.
It returns a JSON configuration for the given participant.
```
cat [GT-FILE] | docker exec -i relamon-session ./transpiler.sh "[PARTICIPANT]>http://[IP]:[PORT],[...]" [IMPL-PORT] [MON-PORT] [PARTICIPANT]
```
Here `[GT-FILE]` is a file containing the global type, for example one in `global-types/`.
The next argument is a comma-separated list of addresses for each other participant; here, `[PARTICIPANT]` is the participant, `[IP]` their ip-address (e.g., `localhost`), `[PORT]` their port.
Next, `[IMPL-PORT]` denotes the implementations port, and `[MON-PORT]` the monitor's port (on `localhost`).
Finally, `[PARTICIPANT]` denotes the participant for which to generate a JSON configuration.

For example, to generate a JSON configuration for the authorization protocol's client participant:
```
cat global-types/csa.gt | docker exec -i relamon-session ./transpiler.sh "s>http://localhost:8001,a>http://localhost:8002" 8080 8000 c
```

## Running the monitoring tool yourself

You need NodeJS and its package manager npm.
Follow the installation guide [here](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm).

Once those requirements are installed, install the packages on which the tool depends:
```
npm install
```

Now, you can run a monitor as follows:
```
PROTOCOL_PATH=[JSON-FILE] node monitor.js
```
Here, `[JSON-FILE]` should point to the JSON configuration of a protocol's participant.

### Example: running the authorization protocol yourself

Run the following commands, in order, and each in a separate terminal from the repository's root directory.
Then, follow the prompts in each terminal.
```
node implementations/CSA/client.js
PROTOCOL_PATH=implementations/CSA/client.json node monitor.js
node implementations/CSA/server.js
PROTOCOL_PATH=implementations/CSA/server.json node monitor.js
node implementations/CSA/authorization.js
PROTOCOL_PATH=implementations/CSA/authorization.json node monitor.js
```

Running the weather API example is similar.

## Running the Rascal transpiler yourself

To run the transpiler, run in a terminal from the repository's root directory:
```
cat [GT-FILE] | ./transpiler.sh "[PARTICIPANT]>http://[IP]:[PORT],[...]" [IMPL-PORT] [MON-PORT] [PARTICIPANT]
```
The arguments are equivalent to running the tool from Docker.

*Note: the Rascal tool is still under development, so we omit documentation on how to run it from an IDE such as VSCode, or how to invoke it directly with the `java` command.*
