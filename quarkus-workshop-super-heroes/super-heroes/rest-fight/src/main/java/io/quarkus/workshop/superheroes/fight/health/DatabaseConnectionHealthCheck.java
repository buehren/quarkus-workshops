package io.quarkus.workshop.superheroes.fight.health;

import io.quarkus.workshop.superheroes.fight.FightService;
import org.eclipse.microprofile.health.HealthCheck;
import org.eclipse.microprofile.health.HealthCheckResponse;
import org.eclipse.microprofile.health.HealthCheckResponseBuilder;
import org.eclipse.microprofile.health.Readiness;

import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

@Readiness
@ApplicationScoped
public class DatabaseConnectionHealthCheck implements HealthCheck {

    @Inject
    FightService fightService;

    @Override
    public HealthCheckResponse call() {
        HealthCheckResponseBuilder responseBuilder = HealthCheckResponse.named("Fight health check");
        try {
            fightService.getFightsCount().subscribe().with(count ->
                responseBuilder.withData("Number of fights in the database", count).up());
        } catch (Exception e) {
            responseBuilder.down().withData("message", e.getMessage());
        }

        return responseBuilder.build();
    }
}
