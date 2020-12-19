cd rest-hero && \
mvn clean package -Pnative -Dnative-image.docker-build=true -DskipTests && \
cd .. && \
cd rest-villain && \
mvn clean package -Pnative -Dnative-image.docker-build=true -DskipTests && \
cd .. && \
cd ui-super-heroes && \
mvn install && \
npm install && \
./package.sh && \
cd .. && \
cd rest-fight && \
cp -R ../ui-super-heroes/dist/* src/main/resources/META-INF/resources && \
mvn clean package -Pnative -Dnative-image.docker-build=true -DskipTests && \
cd .. && \
cd event-statistics && \
mvn clean package -Pnative -Dnative-image.docker-build=true -DskipTests && \
cd ..
