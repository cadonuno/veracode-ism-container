> Current ISM Version : 22.1.10 (25-01-2022)
<!-- ABOUT THE PROJECT -->
## About This Project


veracode-ism is a containerised implementation of Veracode's Internal Scanning Manager (ISM).

The Veracode ISM is an agent to help simplify the scanning of applications that cannot be reached from the public internet. It is a Java agent that connects back to the Veracode platform to create a secure tunnel for scan traffic.


This is not an official Veracode project.


<!-- GETTING STARTED -->
## Getting Started

Pre-built (armv7 / amd64) versions of the veracode-ism image is available on docker hub [hub.docker.com/veracode-ism](https://hub.docker.com/r/wasptree/veracode-ism)

Alternatively build a local image from this repository:


  ```sh
    $ git clone https://gitlab.com/wasptree/veracode-ism
    $ cd veracode-ism
    $ docker build -t veracode-ism .
  ```



<!-- SETUP -->
## Setup

The ISM requires both a valid **Token** and **API Key** to successfully negotiate a secure tunnel.
The veracode-ism must be run initially with just the ISM token to register and generate a valid API Key.

1. Generate a valid ISM token in the Verecode management console: [Veracode Analysis Centre](https://analysiscenter.veracode.com/)
Select Add Endpoint > Linux Endpoint > Copy the Endpoint Key/Token, to register as follows.

2. Run the container to register the ISM token and generate an API Key
   ```sh
   docker run -it wasptree/veracode-ism --token <ism_token>
   ```

   *A successful registration will output the API Key.*
3. With the Token and API Key, you can now start the ISM agent as follows
   ```sh
   docker run -it wasptree/veracode-ism --token <ism_token> --key <api_key>
   ```

Once running the agent will show as Online in the Veracode platform.


<!-- USAGE EXAMPLES -->
## Usage Examples



### Docker Compose
It is likely that you will want to include the veracode-ism in a docker-compose file alongside the application you are scanning.

Docker compose will create a network for each of the services.

Example **docker-compose.yml** for running ISM and application:

```
version: '3'

services:
  veracode-ism:
    image: wasptree/veracode-ism
    tty: true
    container_name: veracode-ism
    hostname: veracode-ism
    restart: always
    command: "--token ${TOKEN} --key ${API_KEY}"

  web-application:
    image: myapp:latest
    container_name: myapp.local
    hostname: myapp.local
    restart: always
```
For handling the Token and API Key it is recommended these are stored outside of your compose file. Docker compose has native support for environment variables. For example:
```
$ export TOKEN=<ISM_TOKEN>
$ export API_KEY=<ISM_API_KEY>

$ docker-compose up -d
```
Alternatively you could place the values within a **.env** file inside the same directory.

Example **.env** file for docker-compose:
```
TOKEN=<ISM_TOKEN>
API_KEY=<ISM_API_KEY>
```

In this example the Veracode DAST scanning engine would be configured to scan http://myapp.local


<!-- To Do -->
## To Do

1. Automate nightly build for Veracode ISM updates
2. Add examples folder with docker-compose examples
3. Improve entrypoint/wrapper for catching sigterm 
