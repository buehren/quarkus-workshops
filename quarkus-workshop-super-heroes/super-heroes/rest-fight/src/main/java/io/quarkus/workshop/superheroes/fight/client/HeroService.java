// tag::adocRestClient[]
package io.quarkus.workshop.superheroes.fight.client;

import io.smallrye.mutiny.Uni;
import io.vertx.mutiny.core.Vertx;
import io.vertx.mutiny.ext.web.client.WebClient;
import io.vertx.mutiny.ext.web.client.predicate.ResponsePredicate;
import io.vertx.mutiny.ext.web.codec.BodyCodec;
import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.eclipse.microprofile.jwt.JsonWebToken;
import org.eclipse.microprofile.rest.client.inject.RegisterRestClient;

import javax.annotation.PostConstruct;
import javax.enterprise.context.ApplicationScoped;
import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

/*
THIS CREATES A BLOCKING CLIENT (in the current version of Quarkus):

@Path("/api/heroes")
@Produces(MediaType.APPLICATION_JSON)
@RegisterRestClient
public interface HeroService {

    @GET
    @Path("/random")
    Uni<Hero> findRandomHero();
}
*/
@ApplicationScoped
public class HeroService {

    @ConfigProperty(name="io.quarkus.workshop.superheroes.fight.client.HeroService/mp-rest/url")
    String baseUrl;

    @Inject
    Vertx vertx;

    @Inject
    @RequestScoped
    JsonWebToken jwt;

    private WebClient client;

    @PostConstruct
    void initialize() {
        this.client = WebClient.create(vertx);
    }

    public Uni<Hero> findRandomHero() {
        return client.getAbs(baseUrl+"/api/heroes/random")
            .putHeader("Authorization", "Bearer "+jwt.getRawToken())
            //.authentication(new TokenCredentials(jwt.getRawToken()))
            .expect(ResponsePredicate.SC_SUCCESS)
            .expect(ResponsePredicate.JSON)
            .as(BodyCodec.json(Hero.class))
            .send()
            .onItem().transform(response -> response.body());
    }
}
// end::adocRestClient[]
