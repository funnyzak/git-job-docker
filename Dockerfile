FROM funnyzak/java-nodejs-python-go-etc:latest

MAINTAINER Leon (silenceace@gmail.com)

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL org.label-schema.vendor="Leon<silenceace@gmail.com>" \
    org.label-schema.name="GitJob" \
    org.label-schema.build-date="${BUILD_DATE}" \
    org.label-schema.description="Pull your project git code into a data volume and trigger run event via Webhook." \
    org.label-schema.url="https://yycc.me" \
    org.label-schema.schema-version="${VERSION}"	\
    org.label-schema.vcs-type="Git" \
    org.label-schema.vcs-ref="${VCS_REF}" \
    org.label-schema.vcs-url="https://github.com/funnyzak/git-job-docker" 

# Set the timezone and locale
ENV TZ Asia/Shanghai
ENV LC_ALL C.UTF-8
ENV LANG=C.UTF-8

ENV PUSHOO_PUSH_PLATFORMS=
ENV PUSHOO_PUSH_TOKENS=

ENV STARTUP_COMMAND=
ENV BEFORE_PULL_COMMANDS=
ENV AFTER_PULL_COMMANDS=

ENV GIT_USER_NAME=funnyzak
ENV GIT_USER_EMAIL=
ENV GIT_REPO_URL=
ENV GIT_BRANCH=
ENV USE_HOOK=1
ENV HOOK_TOKEN=

ENV SERVER_NAME=gitjob

ENV TARGET_DIR /app/target
ENV CODE_DIR /app/code
ENV HOOK_DIR /app/hook
ENV HOOK_LOG_DIR /var/log/webhook

# Install pushoo-cli
RUN npm install -g pushoo-cli

# Create operation folders
RUN mkdir -p ${CODE_DIR} && mkdir -p ${TARGET_DIR} && mkdir -p ${HOOK_DIR} && mkdir -p ${HOOK_LOG_DIR

# Copy hook rule and hook script
COPY conf/hooks.json /app/hook/hooks.json

# Copy scripts to /app/scripts and set permissions
COPY scripts /app/scripts
RUN chmod +x -R /app/scripts

# Add any user custom scripts + set permissions
ADD custom_scripts /custom_scripts
RUN chmod +x -R /custom_scripts

# run nginx with root
RUN sed -i 's/^user [a-z0-9\-]\+/user root/' /etc/nginx/nginx.conf
# http proxy 9000 80 
COPY conf/nginx_default.conf /etc/nginx/sites-available/default

# Expose webhook and nginx port
EXPOSE 80 9000

WORKDIR ${CODE_DIR}

ENTRYPOINT ["/bin/bash", "/app/scripts/entrypoint.sh"]