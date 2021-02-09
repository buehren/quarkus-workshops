// tag::adocTransactional[]
package io.quarkus.workshop.superheroes.fight;

import io.quarkus.workshop.superheroes.fight.client.Hero;
// end::adocTransactional[]
import io.quarkus.workshop.superheroes.fight.client.HeroService;
// tag::adocTransactional[]
import io.quarkus.workshop.superheroes.fight.client.Villain;
// end::adocTransactional[]
import io.quarkus.workshop.superheroes.fight.client.VillainService;
import io.smallrye.mutiny.Multi;
import io.smallrye.mutiny.Uni;
import org.eclipse.microprofile.faulttolerance.Asynchronous;
import org.eclipse.microprofile.reactive.messaging.Channel;
import org.eclipse.microprofile.reactive.messaging.Emitter;
import org.eclipse.microprofile.faulttolerance.Fallback;
import org.eclipse.microprofile.rest.client.inject.RestClient;
// tag::adocTransactional[]
import org.jboss.logging.Logger;

import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import java.time.Duration;
import java.time.Instant;
import java.util.Random;
import java.util.concurrent.Future;
import java.util.concurrent.TimeoutException;

import static javax.transaction.Transactional.TxType.REQUIRED;
import static javax.transaction.Transactional.TxType.SUPPORTS;

@ApplicationScoped
@Transactional(SUPPORTS)
public class FightService {

    // tag::adocRestClient[]
    @Inject
    //@RestClient
    HeroService heroService;

    @Inject
    //@RestClient
    VillainService villainService;

    // end::adocRestClient[]
    // tag::adocKafkaEmitter[]
    @Inject
    @Channel("fights") Emitter<Fight> emitter;

    // end::adocKafkaEmitter[]
    private static final Logger LOGGER = Logger.getLogger(FightService.class);

    private final Random random = new Random();

    public Uni<Long> getFightsCount() {
        return Fight.count();
    }

    public Multi<Fight> findAllFights() {
        return Fight.streamAll();
    }

    public Uni<Fight> findFightById(Long id) {
        return Fight.findById(id);
    }

    @Transactional(REQUIRED)
    public Fight persistFight(Fighters fighters) {
        // Amazingly fancy logic to determine the winner...
        Fight fight;

        int heroAdjust = random.nextInt(20);
        int villainAdjust = random.nextInt(20);

        if ((fighters.hero.level + heroAdjust)
            > (fighters.villain.level + villainAdjust)) {
            fight = heroWon(fighters);
        } else if (fighters.hero.level < fighters.villain.level) {
            fight = villainWon(fighters);
        } else {
            fight = random.nextBoolean() ? heroWon(fighters) : villainWon(fighters);
        }

        fight.fightDate = Instant.now();
        fight.persist(fight);
        // tag::adocKafka[]
        emitter.send(fight);
        // end::adocKafka[]
        return fight;
    }

    private Fight heroWon(Fighters fighters) {
        LOGGER.info("Yes, Hero won :o)");
        Fight fight = new Fight();
        fight.winnerName = fighters.hero.name;
        fight.winnerPicture = fighters.hero.picture;
        fight.winnerLevel = fighters.hero.level;
        fight.loserName = fighters.villain.name;
        fight.loserPicture = fighters.villain.picture;
        fight.loserLevel = fighters.villain.level;
        fight.winnerTeam = "heroes";
        fight.loserTeam = "villains";
        return fight;
    }

    private Fight villainWon(Fighters fighters) {
        LOGGER.info("Gee, Villain won :o(");
        Fight fight = new Fight();
        fight.winnerName = fighters.villain.name;
        fight.winnerPicture = fighters.villain.picture;
        fight.winnerLevel = fighters.villain.level;
        fight.loserName = fighters.hero.name;
        fight.loserPicture = fighters.hero.picture;
        fight.loserLevel = fighters.hero.level;
        fight.winnerTeam = "villains";
        fight.loserTeam = "heroes";
        return fight;
    }

    // tag::adocRestClient[]
    Uni<Fighters> findRandomFighters() {
        LOGGER.info("findRandomFighters: calling findRandomHero");
        Uni<Hero> hero = findRandomHero();
        LOGGER.info("findRandomFighters: calling findRandomVillain");
        Uni<Villain> villain = findRandomVillain();
        LOGGER.info("findRandomFighters: returning Uni.combine");
        return Uni.combine().all().unis(hero,villain).combinedWith((myHero, myVillain) -> {
            LOGGER.info("findRandomFighters: inside combinedWith");
            Fighters fighters = new Fighters();
            fighters.hero = myHero;
            fighters.villain = myVillain;
            return fighters;
        });
    }

    // tag::adocFallback[]
    // @Fallback and @Asynchronous do not work with Uni
    //@Fallback(fallbackMethod = "fallbackRandomHero")
    // end::adocFallback[]
    Uni<Hero> findRandomHero() {
        //return Uni.createFrom().<Hero>nullItem().onItem().delayIt().by(Duration.ofMillis(5000))
        return heroService.findRandomHero()
            .onFailure().recoverWithUni(failure -> { LOGGER.error(failure); return fallbackRandomHero(); })
            .ifNoItem().after(Duration.ofMillis(250)).recoverWithUni(() -> { LOGGER.error("Timeout in findRandomHero"); return fallbackRandomHero(); });
    }

    // tag::adocFallback[]
    // @Fallback and @
    // Asynchronous do not work with Uni
    //@Fallback(fallbackMethod = "fallbackRandomVillain")
    // end::adocFallback[]
    Uni<Villain> findRandomVillain() {
        return villainService.findRandomVillain()
            .onFailure().recoverWithUni(failure -> { LOGGER.error(failure); return fallbackRandomVillain(); })
            .ifNoItem().after(Duration.ofMillis(250)).recoverWithUni(() -> { LOGGER.error("Timeout in findRandomVillain"); return fallbackRandomVillain(); });
    }
    // end::adocRestClient[]

    // tag::adocRestClient[]
    // tag::adocFallback[]

    public Uni<Hero> fallbackRandomHero() {
        LOGGER.warn("Falling back on Hero");
        Hero hero = new Hero();
        hero.name = "Fallback hero";
        hero.picture = "https://dummyimage.com/280x380/1e8fff/ffffff&text=Fallback+Hero";
        hero.powers = "Fallback hero powers";
        hero.level = 1;
        return Uni.createFrom().item(hero);
    }

    public Uni<Villain> fallbackRandomVillain() {
        LOGGER.warn("Falling back on Villain");
        Villain villain = new Villain();
        villain.name = "Fallback villain";
        villain.picture = "https://dummyimage.com/280x380/b22222/ffffff&text=Fallback+Villain";
        villain.powers = "Fallback villain powers";
        villain.level = 42;
        return Uni.createFrom().item(villain);
    }
    // end::adocFallback[]
    // end::adocRestClient[]
}
// end::adocTransactional[]
