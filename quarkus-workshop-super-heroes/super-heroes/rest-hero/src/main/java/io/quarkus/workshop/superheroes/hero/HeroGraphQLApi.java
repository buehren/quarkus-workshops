// tag::adocResource[]
package io.quarkus.workshop.superheroes.hero;

import io.smallrye.mutiny.Multi;
import io.smallrye.mutiny.Uni;
import org.eclipse.microprofile.graphql.Description;
import org.eclipse.microprofile.graphql.GraphQLApi;
import org.eclipse.microprofile.graphql.Query;
import org.eclipse.microprofile.jwt.JsonWebToken;
import org.eclipse.microprofile.metrics.MetricUnits;
import org.eclipse.microprofile.metrics.annotation.Counted;
import org.eclipse.microprofile.metrics.annotation.Timed;
import org.jboss.logging.Logger;

import javax.annotation.security.PermitAll;
import javax.annotation.security.RolesAllowed;
import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import java.util.List;

@GraphQLApi
@RolesAllowed("**")
public class HeroGraphQLApi {

    private static final Logger LOGGER = Logger.getLogger(HeroGraphQLApi.class);

    @Inject
    @RequestScoped
    JsonWebToken jwt;

    @Inject
    HeroService service;

    // $ http POST :8083/graphql query='{ randomHero { id name otherName powers picture level } }' Authorization:'Bearer .....'
    // http://localhost:8083/q/graphql-ui/?query=%7B%20randomHero%20%7B%20id%20name%20otherName%20powers%20picture%20level%20%7D%20%7D&headers=%7B%20%22Authorization%22%3A%20%22Bearer%20...%22%7D
    @Query("randomHero")
    @Description("Returns a random hero")
    // tag::adocMetrics[]
    @Counted(name = "countGetRandomHero", description = "Counts how many times the getRandomHero method has been invoked")
    @Timed(name = "timeGetRandomHero", description = "Times how long it takes to invoke the getRandomHero method", unit = MetricUnits.MILLISECONDS)
    // end::adocMetrics[]
    public Uni<Hero> randomHero() {
        LOGGER.info("getRandomHero: Start. jwt="+jwt);

        Uni<Hero> hero = service.findRandomHero();

        LOGGER.info("getRandomHero: Returning hero: " + hero);
        return hero;

        /*
        Hero hero1 = new Hero();
        hero1.name = "Karl";
        hero1.level = 10;
        hero1.otherName = "OtherKarl";
        hero1.powers = "Austin";
        hero1.picture = "frame";
        hero1.id = 1L;
        return Uni.createFrom().item(hero1);
        */
    }
    // end::adocMetricsMethods[]

    // $ http POST :8083/graphql query='{ allHeroes { id name otherName powers picture level } }' Authorization:'Bearer .....'
    // tag::adocOpenAPI[]
    @Query("allHeroes")
    @Description("Returns all the heroes from the database")
    // end::adocOpenAPI[]
    // tag::adocMetrics[]
    @Counted(name = "countGetAllHeroes", description = "Counts how many times the getAllHeroes method has been invoked")
    @Timed(name = "timeGetAllHeroes", description = "Times how long it takes to invoke the getAllHeroes method", unit = MetricUnits.MILLISECONDS)
    // end::adocMetrics[]
    //public Multi<Hero> allHeroes() {  TODO: SmallRyeGraphQLProcessor#buildExecutionService threw an exception: java.lang.NullPointerException
    public Uni<List<Hero>> allHeroes() {
        LOGGER.info("getAllHeroes: Start");

        Multi<Hero> heroes = service.findAllHeroes();
        LOGGER.info("getAllHeroes: Returning all heroes: " + heroes);

        return heroes.collect().asList();
    }

/*
    @Query("allHeroesDelayed")
    @Description("Returns all the heroes from the database with a delay between each of them")
    public Multi<Hero> allHeroesDelayed() {
        LOGGER.info("getAllHeroesDelayed: Start");

        Multi<Hero> heroes = service
            .findAllHeroes()
            .onItem().call(i ->
                // Delay the emission until the returned uni emits its item
                Uni.createFrom().nullItem().onItem().delayIt().by(Duration.ofMillis(1000))
            );

        LOGGER.info("getAllHeroesDelayed: Returning all heroes (delayed): " + heroes);

        return heroes;
    }

/*
    // https://github.com/quarkusio/quarkus/issues/13794
    // https://quarkus.io/guides/reactive-messaging-http.html#websockets
    @Outgoing("heroes-delayed-out")
    public Multi<Hero> allHeroesDelayedWebsocket() {
        LOGGER.info("getAllHeroesDelayedWebsocket: Start");

        Multi<Hero> heroes = service
            .findAllHeroes()
            .onItem().call(i ->
                // Delay the emission until the returned uni emits its item
                Uni.createFrom().nullItem().onItem().delayIt().by(Duration.ofMillis(1000))
            );

        LOGGER.info("getAllHeroesDelayedWebsocket: Returning all heroes (delayed): " + heroes);

        return heroes;
    }
* /


    // tag::adocOpenAPI[]
    @Query("hero")
    @Description("Returns a hero for a given identifier")
    // end::adocOpenAPI[]
    // tag::adocMetrics[]
    @Counted(name = "countGetHero", description = "Counts how many times the getHero method has been invoked")
    @Timed(name = "timeGetHero", description = "Times how long it takes to invoke the getHero method", unit = MetricUnits.MILLISECONDS)
    // end::adocMetrics[]
    public Uni<Hero> hero(Long id) {
        return service.findHeroById(id);
    }

    // tag::adocOpenAPI[]
    @Query("createHero")
    @Description("Creates a valid hero")
    // end::adocOpenAPI[]
    // tag::adocMetrics[]
    @Counted(name = "countCreateHero", description = "Counts how many times the createHero method has been invoked")
    @Timed(name = "timeCreateHero", description = "Times how long it takes to invoke the createHero method", unit = MetricUnits.MILLISECONDS)
    // end::adocMetrics[]
    public Uni<Hero> createHero(@Valid Hero hero) {
        return Uni.createFrom().item(service.persistHero(hero));
    }

    // tag::adocOpenAPI[]
    @Query("updateHero")
    @Description("Updates an exiting hero")
    // end::adocOpenAPI[]
    // tag::adocMetrics[]
    @Counted(name = "countUpdateHero", description = "Counts how many times the updateHero method has been invoked")
    @Timed(name = "timeUpdateHero", description = "Times how long it takes to invoke the updateHero method", unit = MetricUnits.MILLISECONDS)
    // end::adocMetrics[]
    public Uni<Hero> updateHero(@Valid Hero hero) {
        return service.updateHero(hero);
    }

    // tag::adocOpenAPI[]
    @Query("deleteHero")
    @Description("Deletes an exiting hero")
    // end::adocOpenAPI[]
    // tag::adocMetrics[]
    @Counted(name = "countDeleteHero", description = "Counts how many times the deleteHero method has been invoked")
    @Timed(name = "timeDeleteHero", description = "Times how long it takes to invoke the deleteHero method", unit = MetricUnits.MILLISECONDS)
    // end::adocMetrics[]
    public void deleteHero(Long id) {
        service.deleteHero(id);
        LOGGER.debug("Hero will be deleted with " + id);
    }
*/

    // $ http POST :8083/graphql query='{ hello }'
    @Query("hello")
    @PermitAll
    public String hello() {
        return "hello from microprofile graphql api";
    }
}
// end::adocResource[]
