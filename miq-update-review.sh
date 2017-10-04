cd manageiq
git fetch upstream && git checkout master && git merge upstream/master --ff-only
cd ..

cd manageiq-ui-classic
git fetch upstream && git checkout master && git merge upstream/master --ff-only
cd ..

cd manageiq
./bin/update
