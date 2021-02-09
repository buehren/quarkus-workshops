// tag::adocTest[]
package io.quarkus.workshop.superheroes.fight.client;

import io.quarkus.test.Mock;
import io.smallrye.mutiny.Uni;
import org.eclipse.microprofile.rest.client.inject.RestClient;

import javax.enterprise.context.ApplicationScoped;

@Mock
@ApplicationScoped
@RestClient
public class MockHeroService extends HeroService {

    public static final String DEFAULT_HERO_NAME = "Super Baguette";
    public static final String DEFAULT_HERO_PICTURE = "super_baguette.png";
    public static final String DEFAULT_HERO_POWERS = "eats baguette really quickly";
    public static final int DEFAULT_HERO_LEVEL = 42;

    @Override
    public Uni<Hero> findRandomHero() {
        Hero hero = new Hero();
        hero.name = DEFAULT_HERO_NAME;
        hero.picture = DEFAULT_HERO_PICTURE;
        hero.powers = DEFAULT_HERO_POWERS;
        hero.level = DEFAULT_HERO_LEVEL;
        return Uni.createFrom().item(hero);
    }
}
// end::adocTest[]
