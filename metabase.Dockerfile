FROM metabase/metabase:v0.34.3
ADD https://github.com/dacort/metabase-athena-driver/releases/download/v0.1.0/athena.metabase-driver.jar plugins/
ENV MGID=${MGID:-2000}
ENV MUID=${MUID:-2000}
ENV JAVA_TOOL_OPTIONS "-XX:+UseContainerSupport -XX:+PrintFlagsFinal"
RUN addgroup -g $MGID -S metabase
RUN adduser -D -u $MUID -G metabase metabase
RUN chown metabase:metabase plugins/athena.metabase-driver.jar