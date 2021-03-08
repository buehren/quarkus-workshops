// tag::adocWebSocket[]
package io.quarkus.workshop.superheroes.statistics;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ObjectWriter;
import io.smallrye.mutiny.Multi;
import org.eclipse.microprofile.reactive.messaging.Channel;
import org.jboss.logging.Logger;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;
import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import javax.websocket.OnClose;
import javax.websocket.OnMessage;
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
    private String lastPublishedJson;

    @Inject @Channel("winner-stats")
    Multi<Iterable<Score>> winners;

    private List<Session> sessions = new CopyOnWriteArrayList<>();
//    private Disposable subscription;

    @OnOpen
    public void onOpen(Session session) {
        sessions.add(session);
        if (lastPublishedJson!=null) {
            write(session, lastPublishedJson);
        }
        var logMessage = "TopWinnerWebSocket.onOpen: " +
            "session.id="+session.getId()+", subprot="+session.getNegotiatedSubprotocol()+", " +
            "ext="+session.getNegotiatedExtensions()+", session="+session+", " +
            "lastPublishedJson="+lastPublishedJson;
        LOGGER.info(logMessage);
    }

    @OnClose
    public void onClose(Session session) {
        sessions.remove(session);
        LOGGER.info("TopWinnerWebSocket.onClose: session.id="+session.getId()+", subprot="+session.getNegotiatedSubprotocol()+", ext="+session.getNegotiatedExtensions()+", session="+session);
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
            .subscribe().with(serialized -> {
                    lastPublishedJson = serialized;
                    sessions.forEach(session -> write(session, serialized));
                },
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

    @OnMessage
    public void onMessage(Session session, String message) {
        LOGGER.info("Received WebSocket message: "+message);
    }
}
// end::adocWebSocket[]
