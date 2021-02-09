// tag::adocDatabaseConnection[]
package io.quarkus.workshop.superheroes.hero.health;

import io.quarkus.workshop.superheroes.hero.Hero;
import io.quarkus.workshop.superheroes.hero.HeroService;
import org.eclipse.microprofile.health.HealthCheck;
import org.eclipse.microprofile.health.HealthCheckResponse;
import org.eclipse.microprofile.health.HealthCheckResponseBuilder;
import org.eclipse.microprofile.health.Readiness;

import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import java.util.List;

@Readiness
@ApplicationScoped
public class DatabaseConnectionHealthCheck implements HealthCheck {

    @Inject
    HeroService heroService;

    @Override
    public HealthCheckResponse call() {
        HealthCheckResponseBuilder responseBuilder = HealthCheckResponse
            .named("Hero Datasource connection health check");

        try {
            heroService.getHeroesCount().subscribe().with(count ->
                responseBuilder.withData("Number of heroes in the database", count).up());
        } catch (IllegalStateException e) {
            responseBuilder.down();
        }

        return responseBuilder.build();
    }
}
// end::adocDatabaseConnection[]
