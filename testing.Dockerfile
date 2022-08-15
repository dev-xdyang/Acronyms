FROM swift:5.6-focal as build

WORKDIR /package

COPY . ./

CMD ["swift", "test", "--enable-test-discovery"]
