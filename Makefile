docker-build: docker build -t strapicms:latest .

docker-run: docker run -d --name strapi -p 1337:1337 --env-file .env --platform linux/amd64 strapicms:latest
