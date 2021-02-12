// tag::adocWebSocket[]
package io.quarkus.workshop.superheroes.statistics;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ObjectWriter;
import io.reactivex.Flowable;
import io.reactivex.disposables.Disposable;
import io.smallrye.mutiny.Multi;
import org.eclipse.microprofile.reactive.messaging.Channel;
import org.jboss.logging.Logger;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;
import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import javax.websocket.OnClose;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

@ServerEndpoint("/stats/winners")
@ApplicationScoped
public class TopWinnerWebSocket {

    private static final Logger LOGGER = Logger.getLogger(TopWinnerWebSocket.class);
    private ObjectWriter objectWriter;

    @Inject @Channel("winner-stats")
    Multi<Iterable<Score>> winners;

    private List<Session> sessions = new CopyOnWriteArrayList<>();
//    private Disposable subscription;

    @OnOpen
    public void onOpen(Session session) {
        sessions.add(session);
    }

    @OnClose
    public void onClose(Session session) {
        sessions.remove(session);
    }

    @PostConstruct
    public void subscribe() {
        objectWriter = new ObjectMapper().writer(); //.withDefaultPrettyPrinter();
        winners
            .map(scores -> {
                    try {
                        return objectWriter.writeValueAsString(scores);
                    } catch (JsonProcessingException jpe) {
                        throw new Error(jpe);
                    }
                })
            .subscribe().with(serialized -> sessions.forEach(session -> write(session, serialized)),
                failure -> LOGGER.error("TopWinnerWebSocket.subscribe() failed with " + failure, failure),
                () -> LOGGER.info("Completed TopWinnerWebSocket.subscribe()"));
    }

    @PreDestroy
    public void cleanup() throws Exception {
//        subscription.dispose();
    }

    private void write(Session session, String serialized) {
        session.getAsyncRemote().sendText(serialized, result -> {
            if (result.getException() != null) {
                LOGGER.error("Unable to write message to web socket", result.getException());
            }
        });
    }
}
// end::adocWebSocket[]
