// tag::adocTransactional[]
package io.quarkus.workshop.superheroes.hero;

// end::adocTransactional[]
import io.smallrye.mutiny.Multi;
import io.smallrye.mutiny.Uni;
import org.eclipse.microprofile.config.inject.ConfigProperty;
// tag::adocTransactional[]
import javax.enterprise.context.ApplicationScoped;
import javax.transaction.Transactional;
import javax.validation.Valid;

import static javax.transaction.Transactional.TxType.REQUIRED;
import static javax.transaction.Transactional.TxType.SUPPORTS;

@ApplicationScoped
@Transactional(REQUIRED)
public class HeroService {

    // tag::adocConfigProperty[]
    @ConfigProperty(name = "level.multiplier", defaultValue="1")
    int levelMultiplier;
    // end::adocConfigProperty[]

    @Transactional(SUPPORTS)
    public Uni<Long> getHeroesCount() {
        return Hero.count();
    }

    @Transactional(SUPPORTS)
    public Multi<Hero> findAllHeroes() {
        return Hero.streamAll();
    }

    @Transactional(SUPPORTS)
    public Uni<Hero> findHeroById(Long id) {
        return Hero.findById(id);
    }

    @Transactional(SUPPORTS)
    public Uni<Hero> findRandomHero() {
        return Hero.findRandom();
    }

    // tag::adocPersistHero[]
    public Hero persistHero(@Valid Hero hero) {
        // tag::adocPersistHeroLevel[]
        hero.level = hero.level * levelMultiplier;
        // end::adocPersistHeroLevel[]
        Hero.persist(hero);
        return hero;
    }
    // end::adocPersistHero[]

    public Uni<Hero> updateHero(@Valid Hero hero) {
        Uni<Hero> entity = Hero.findById(hero.id);
        entity.onItem().transform(heroItem -> {
            heroItem.name = hero.name;
            heroItem.otherName = hero.otherName;
            heroItem.level = hero.level;
            heroItem.picture = hero.picture;
            heroItem.powers = hero.powers;
            return heroItem.persist();
        });
        return entity;
    }

    public void deleteHero(Long id) {
        Hero.deleteById(id);
    }
}
// end::adocTransactional[]
