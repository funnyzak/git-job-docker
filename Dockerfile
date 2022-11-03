FROM funnyzak/java-nodejs-python-go-etc:1.3.1

LABEL maintainer="leon (github.com/funnyzak)"

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.vendor="yycc<silenceace@gmail.com>" \
    org.label-schema.name="GitJob" \
    org.label-schema.build-date="${BUILD_DATE}" \
    org.label-schema.description="Pull your project git code into a data volume and trigger run event via Webhook." \
    org.label-schema.url="https://yycc.me" \
    org.label-schema.schema-version="1.1.0"	\
    org.label-schema.vcs-type="Git" \
    org.label-schema.vcs-ref="${VCS_REF}" \
    org.label-schema.vcs-url="https://github.com/funnyzak/git-job-docker" 

ENV LANG=C.UTF-8

# Create Dir
RUN mkdir -p /app/hook && mkdir -p /app/code && mkdir -p /var/log/webhook

# Copy webhook config
COPY conf/hooks.json /app/hook/hooks.json
COPY scripts/hook.sh /app/hook/hook.sh

# Copy our Scripts
COPY scripts/start.sh /usr/bin/start.sh
COPY scripts/utils.sh /app/scripts/utils.sh
COPY scripts/run_scripts_after_pull.sh /usr/bin/run_scripts_after_pull.sh
COPY scripts/run_scripts_before_pull.sh /usr/bin/run_scripts_before_pull.sh
COPY scripts/run_scripts_on_startup.sh /usr/bin/run_scripts_on_startup.sh
COPY scripts/run_scripts_after_package.sh /usr/bin/run_scripts_after_package.sh

# Add permissions to our scripts
RUN chmod +x /app/scripts/utils.sh
RUN chmod +x /app/hook/hook.sh
RUN chmod +x /usr/bin/run_scripts_after_pull.sh
RUN chmod +x /usr/bin/run_scripts_before_pull.sh
RUN chmod +x /usr/bin/run_scripts_on_startup.sh
RUN chmod +x /usr/bin/run_scripts_after_package.sh

# Add any user custom scripts + set permissions
ADD custom_scripts /custom_scripts
RUN chmod +x -R /custom_scripts

RUN chmod +x -R /app/code

# run nginx with root
RUN sed -i 's/^user [a-z0-9\-]\+/user root/' /etc/nginx/nginx.conf
# http proxy 9000 80 
COPY conf/nginx_default.conf /etc/nginx/sites-available/default

# create final target folder
RUN mkdir -p /app/target/

# Expose Webhook、nginx port
EXPOSE 80 9000

WORKDIR /app/code

# run start script
ENTRYPOINT ["/bin/bash", "/usr/bin/start.sh"]
