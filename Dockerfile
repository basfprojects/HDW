FROM node:14.16.1 as build
WORKDIR /usr/scr/app

COPY package.json ./
COPY . .

RUN npm install
##RUN npm install @angular/cli
##RUN ng build  --output-path "dist" --aot=true --delete-output-path=false
##RUN npm run build --output-path "dist" --aot=true --delete-output-path=false

RUN ./node_modules/.bin/ng build  --output-path "dist" --aot=true --delete-output-path=false

#STAGE 2
FROM nginx:stable-alpine AS production

WORKDIR /usr/share/nginx/html

COPY --from=build usr/scr/app/dist .

# Copy the specific nginx.conf we need for ng...
COPY nginx.conf /etc/nginx/nginx.conf

# see http://pjdietz.com/2016/08/28/nginx-in-docker-without-root.html
RUN touch /var/run/nginx.pid && \
  chown -R nginx:nginx /var/run/nginx.pid && \
  chown -R nginx:nginx /var/cache/nginx

# run as non-root
USER nginx

EXPOSE 8080