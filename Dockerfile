FROM eclipse-temurin:17-jdk-alpine

ARG user=spring
ARG group=spring
ENV SPRING_HOME=/home/spring

RUN addgroup -g 1000 ${group} \
    && adduser -D -h "$SPRING_HOME" -u 1000 -G ${group} ${user} \
    && mkdir -p $SPRING_HOME/{config,logs} \
    && chown -R ${user}:${group} $SPRING_HOME
	
# Railway 不支持使用 VOLUME, 本地需要构建时，取消下一行的注释
#VOLUME ["$SPRING_HOME/config", "$SPRING_HOME/logs"]

USER ${user}
WORKDIR $SPRING_HOME

COPY . .

RUN mvn clean package \
    && mv target/midjourney-proxy-*.jar ./app.jar \
    && rm -rf target

EXPOSE 8080 9876

ENV JAVA_OPTS -XX:MaxRAMPercentage=85 -Djava.awt.headless=true -XX:+HeapDumpOnOutOfMemoryError \
 -XX:MaxGCPauseMillis=20 -XX:InitiatingHeapOccupancyPercent=35 -Xlog:gc:file=/home/spring/logs/gc.log \
 -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=9876 -Dcom.sun.management.jmxremote.ssl=false \
 -Dcom.sun.management.jmxremote.authenticate=false -Dlogging.file.path=/home/spring/logs \
 -Dserver.port=8080 -Duser.timezone=Asia/Shanghai

ENTRYPOINT ["bash","-c","java $JAVA_OPTS -jar app.jar"]
