
if [ -f ./.env.local ]; then
	source ./.env.local
fi
docker build -t myown-androidsdk-proxyfs .
