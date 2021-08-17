FROM klakegg/hugo:0.87.0-ext-alpine
RUN apk add --no-cache openssl

WORKDIR /site

ENTRYPOINT ["hugo"]
CMD ["server", "--bind=0.0.0.0"]
