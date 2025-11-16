FROM nginx:1.21-alpine
COPY ./apps/frontend /usr/share/nginx/html
