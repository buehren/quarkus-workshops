// tag::adocPingHero[]
package io.quarkus.workshop.superheroes.hero.health;

import io.quarkus.workshop.superheroes.hero.HeroRestResource;
import org.eclipse.microprofile.health.HealthCheck;
import org.eclipse.microprofile.health.HealthCheckResponse;
import org.eclipse.microprofile.health.Liveness;

import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;

@Liveness
@ApplicationScoped
public class PingHeroResourceHealthCheck implements HealthCheck {

    @Inject
    HeroRestResource heroRestResource;

    @Override
    public HealthCheckResponse call() {
        heroRestResource.hello();
        return HealthCheckResponse.named("Ping Hero REST Endpoint").up().build();
    }
}
// end::adocPingHero[]
