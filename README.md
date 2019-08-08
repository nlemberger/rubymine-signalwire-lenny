# Example RubyMine Setup with WSL and Signalwire "Lenny" Example

## WARNING
This was written after the fact, so packages or steps may be missing.  Please let me know and I'll update/add as incorrect or missing pieces are discovered.  Use at your own risk, these are effectively written as notes to myself.

## Setup Machine
* Install Windows Subsystem for Linux
* Install build packages in Ubuntu 

  `build-essential npm rake ruby-dev ruby-full zlib1g zlib1g-dev zlibc`
* Install common gems

  `webrick signalwire localtunnel ruby-debug-ide zlib openssl rake`

## Setup RubyMine
* Add Ruby SDK using settings dialog, set it to "WSL"

## Playground!
* Standard 'play' and 'debug' functionality should work
* Lenny example uses localtunnel to setup a host @ localtunnel.me so that SignalWire can fetch resources from the local machine's project directory.
  * THIS MEANS THAT THE PROJECT DIRECTORY IS AVAILABLE ON THE INTERNET!!! One would need to know the hostname, but use at your own risk.
