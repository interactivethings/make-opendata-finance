# update the package manager list
apt-get update

# install dependencies
apt-get install curl build-essential git-core libxml2 libxml2-dev libxslt1-dev -y

# install rvm
curl -L https://get.rvm.io | bash -s stable --ruby=1.9.3
source /usr/local/rvm/scripts/rvm
gem install middleman
gem install bundler

# install node.js
git clone git://github.com/joyent/node.git
cd node/
git checkout v0.8.19
make
make install
cd -

cd /vagrant
bundle install
bundle exec rake install
bundle exec rake server
