# Docker container for FHEM PRESENCE/collectord
A supportative containerto run FHEM's [collectord](https://wiki.fhem.de/wiki/PRESENCE#.C3.9Cberwachung_durch_verteilte_Agenten_in_der_Wohnung_.28presenced.2Flepresenced.2Fcollectord.29) (part of the [PRECENSE module](http://fhem.de/commandref.html#PRESENCE)).

### Image flavors
This image provides 2 different variants:

- `latest` (default)
- `dev`

You can use one of those variants by adding them to the docker image name like this:

	docker pull homeautomationstack/fhem-collectord:latest

If you do not specify any variant, `latest` will always be the default.

`latest` will give you the current stable version.
`dev` will give you the latest development version.


### Supported platforms
This is a multi-platform image, providing support for the following platforms:


Linux:

- `x86-64/AMD64` [Link](https://hub.docker.com/r/homeautomationstack/fhem-collectord-amd64_linux/)
- `i386` [Link](https://hub.docker.com/r/homeautomationstack/fhem-collectord-i386_linux/)
- `ARM32v5, armel` [Link](https://hub.docker.com/r/homeautomationstack/fhem-collectord-arm32v5_linux/)
- `ARM32v7, armhf` [Link](https://hub.docker.com/r/homeautomationstack/fhem-collectord-arm32v7_linux/)
- `ARM64v8, arm64` [Link](https://hub.docker.com/r/homeautomationstack/fhem-collectord-arm64v8_linux/)


Windows:

- currently not supported


The main repository will allow you to install on any of these platforms.
In case you would like to specifically choose your platform, go to the platform.related repositories by clicking on the respective link above.

The platform repositories will also allow you to choose more specific build tags beside the rolling tags latest, current and dev.


## Usage

#### collectord.conf
The collectord daemon uses a configuration file from the attached Docker volume /data.

1. Create data folder on your host together with a file named `collectord.conf`.
2. Put your configuration into the `collectord.conf` file. See [instructions on the FHEM wiki pages](https://wiki.fhem.de/wiki/PRESENCE#Konfiguration_auf_Shellebene).
3. Start your container with a specific volume `-v /my/data/path/:/data/` to make that data available to the container.

___
[Production ![Build Status](https://travis-ci.com/docker-home-automation-stack/fhem-collectord.svg?branch=master)](https://travis-ci.com/docker-home-automation-stack/fhem-collectord)

[Development ![Build Status](https://travis-ci.com/docker-home-automation-stack/fhem-collectord.svg?branch=dev)](https://travis-ci.com/docker-home-automation-stack/fhem-collectord)
