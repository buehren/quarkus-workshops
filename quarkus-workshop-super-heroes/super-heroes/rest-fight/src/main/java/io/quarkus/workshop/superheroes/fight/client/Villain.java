// tag::adocBean[]
package io.quarkus.workshop.superheroes.fight.client;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import javax.validation.constraints.NotNull;

@Schema(description="The villain fighting against the hero")
@JsonIgnoreProperties(ignoreUnknown = true)
public class Villain {

    @NotNull
    public String name;
    @NotNull
    public int level;
    @NotNull
    public String picture;
    public String powers;

    // tag::adocSkip[]
    @Override
    public String toString() {
        return "Villain{" +
            "name='" + name + '\'' +
            ", level=" + level +
            ", picture='" + picture + '\'' +
            ", powers='" + powers + '\'' +
            '}';
    }
    // end::adocSkip[]
}
// end::adocBean[]
