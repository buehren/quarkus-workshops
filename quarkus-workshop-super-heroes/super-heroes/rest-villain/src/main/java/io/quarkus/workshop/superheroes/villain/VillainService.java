// tag::adocTransactional[]
package io.quarkus.workshop.superheroes.villain;

import io.smallrye.mutiny.Multi;
import io.smallrye.mutiny.Uni;
import org.bson.types.ObjectId;
import org.eclipse.microprofile.config.inject.ConfigProperty;

import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import javax.validation.Valid;

import static javax.transaction.Transactional.TxType.REQUIRED;
import static javax.transaction.Transactional.TxType.SUPPORTS;

@ApplicationScoped
@Transactional(REQUIRED)
public class VillainService {

    @Inject
    VillainRepository repository;

    @ConfigProperty(name = "level.multiplier", defaultValue="1")
    int levelMultiplier;

    @Transactional(SUPPORTS)
    public Uni<Long> getVillainsCount() {
        return repository.count();
    }

    @Transactional(SUPPORTS)
    public Multi<Villain> findAllVillains() {
        return repository.streamAll();
    }

    @Transactional(SUPPORTS)
    public Uni<Villain> findVillainById(String id) {
        return repository.findById(new ObjectId(id));
    }

    @Transactional(SUPPORTS)
    public Uni<Villain> findRandomVillain() {
        return repository.findRandom();
    }

    public Uni<Void> persistVillain(@Valid Villain villain) {
        villain.level = villain.level * levelMultiplier;
        return repository.persist(villain);
    }

    public Uni<Villain> updateVillain(@Valid Villain villain) {
        Uni<Villain> entity = Villain.findById(villain.id);
        entity.onItem().transform(villainItem -> {
            villainItem.name = villain.name;
            villainItem.otherName = villain.otherName;
            villainItem.level = villain.level;
            villainItem.picture = villain.picture;
            villainItem.powers = villain.powers;
            return villainItem.persist();
        });
        return entity;
    }

    public void deleteVillain(String id) {
        repository.deleteById(new ObjectId(id));
    }
}
// end::adocTransactional[]
