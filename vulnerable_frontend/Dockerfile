FROM node:18-alpine

WORKDIR /usr/app

COPY . .
RUN npm install

EXPOSE 8080
CMD ["node", "index.js"]

