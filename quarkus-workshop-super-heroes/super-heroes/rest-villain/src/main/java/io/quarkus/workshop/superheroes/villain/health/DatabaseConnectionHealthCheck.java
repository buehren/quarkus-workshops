package io.quarkus.workshop.superheroes.villain.health;

import io.quarkus.workshop.superheroes.villain.VillainService;
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
    VillainService villainService;

    @Override
    public HealthCheckResponse call() {
        HealthCheckResponseBuilder responseBuilder = HealthCheckResponse.named("Villain health check");
        try {
            villainService.getVillainsCount().subscribe().with(count ->
                responseBuilder.withData("Number of villains in the database", count).up());
        } catch (Exception e) {
            responseBuilder.down().withData("message", e.getMessage());
        }

        return responseBuilder.build();
    }
}
