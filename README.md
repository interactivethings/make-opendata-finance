# IXT App Template for Middleman 3.0.x

Features:

* Front-end dependency management via [Bower][]
* Includes our own JS/SASS extensions and defaults (see `lib/assets/`)
* Useful default configuration (e.g. relative assets)
* Default layout based on Bootstrap, to quickly kick-start and prototype apps
* Easy deployment to SSH and S3 hosts


## Usage

### Install

First, do

    gem install middleman

To make this template available to Middleman, clone (or symlink) this repo into `~/.middleman`.

To initialize a new project, create a directory, navigate to it, and run

    middleman init . --template middleman-ixt-app

To install all bundled gems and Bower components run

    rake install

(Also do this each time after you edit the `Gemfile` or `component.json`)


### Adding front-end libraries (a.k.a Bower Components)

Thanks to [Bower][] you'll (almost) never have to track down and download front-end libraries yourself anymore. Any JS/CSS dependencies are specified in `component.json`.

To quickly add a new library type

    bower install jquery --save

The `--save` flag automatically adds the library to `component.json`.

You can also edit `component.json` yourself and then run

    bower install

### Running a local development server

Run

    rake server

and open `localhost:4567` in your Browser.


### Build

To build the project run

    rake build

To build and pack it up in a ZIP archive run

    rake pack_build

### Deployment

Configure the different staging and production remotes in `remotes.yml`.

Example configuration:

    staging:
      service: rsync
      user: interact
      host: interactivethings.com
      path: /home/interact/www/ixt-deploy-test

    production:
      service: s3
      bucket: ixt-deploy-test

To deploy to each remote run

    rake deploy:staging

or

    rake deploy:production



[Bower]: https://github.com/twitter/bower
