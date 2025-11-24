FROM nginx:alpine

ARG API_URL
ENV API_URL=$API_URL

COPY index.html /usr/share/nginx/html/index.html

RUN sed -i "s|NOTES_API_URL|$API_URL|g" /usr/share/nginx/html/index.html

EXPOSE 80
