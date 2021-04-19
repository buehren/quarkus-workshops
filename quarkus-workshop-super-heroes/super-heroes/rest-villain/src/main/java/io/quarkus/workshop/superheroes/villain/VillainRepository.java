package io.quarkus.workshop.superheroes.villain;

import io.quarkus.mongodb.panache.reactive.ReactivePanacheMongoRepository;
import io.smallrye.mutiny.Uni;
import org.bson.Document;

import javax.enterprise.context.ApplicationScoped;
import java.util.List;

@ApplicationScoped
public class VillainRepository implements ReactivePanacheMongoRepository<Villain> {
    public Uni<Villain> findRandom() {
        return mongoCollection()
            .aggregate(List.of(
                new Document().append("$sample",new Document().append("size",1))))
            .toUni();
    }
}
