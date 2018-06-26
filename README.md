
# Smashing Team dashboard

## Pre-requisites

* Ruby 2.4.2
* Node 10

## Installation

### mongo

Check https://docs.mongodb.com/manual/installation/ for OS-specific installation instructions

Do this on ubuntu

```sudo apt install linuxbrew-wrapper
brew update
brew install mongodbrew install mongodb
sudo mkdir -p /data/db
sudo apt install mongodb-server
```

### Smashing

```sudo gem install bundler
sudo gem install smashing
smashing new team_dashboard
cd team_dashboard
bundle install
```

...then copy in all the code from the repo. It should then run with:

```smashing start
```

Note: If no data is sent to the dashboard, use this instead of smashing start

```rackup -p 3030 -s webrick
```

...accessible on:

```http://localhost:3030/team
```
