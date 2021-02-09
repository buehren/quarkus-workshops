// tag::adocResource[]
package io.quarkus.workshop.superheroes.fight;

// end::adocResource[]
import io.smallrye.mutiny.Multi;
import io.smallrye.mutiny.Uni;
import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.eclipse.microprofile.faulttolerance.Timeout;
import org.eclipse.microprofile.metrics.MetricUnits;
import org.eclipse.microprofile.metrics.annotation.Counted;
import org.eclipse.microprofile.metrics.annotation.Timed;
// tag::adocResource[]
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.enums.SchemaType;
import org.eclipse.microprofile.openapi.annotations.media.Content;
import org.eclipse.microprofile.openapi.annotations.media.Schema;
import org.eclipse.microprofile.openapi.annotations.parameters.Parameter;
import org.eclipse.microprofile.openapi.annotations.parameters.RequestBody;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;
import org.jboss.logging.Logger;

import javax.inject.Inject;
import javax.validation.Valid;
import javax.ws.rs.*;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.UriInfo;

import static java.time.Duration.ofSeconds;
import static javax.ws.rs.core.MediaType.APPLICATION_JSON;
import static javax.ws.rs.core.MediaType.TEXT_PLAIN;

@Path("/api/fights")
@Produces(APPLICATION_JSON)
public class FightResource {

    private static final Logger LOGGER = Logger.getLogger(FightResource.class);

    @Inject
    FightService service;

    // tag::adocFaultTolerance[]
    // tag::adocTimeout[]
    @ConfigProperty(name = "process.milliseconds", defaultValue="0")
    long tooManyMilliseconds;

    private void veryLongProcess() throws InterruptedException {
        Thread.sleep(tooManyMilliseconds);
    }

    // end::adocTimeout[]
    @Operation(summary = "Returns two random fighters")
    @APIResponse(responseCode = "200", content = @Content(mediaType = APPLICATION_JSON, schema = @Schema(implementation = Fighters.class, required = true)))
    // tag::adocMetrics[]
    @Counted(name = "countGetRandomFighters", description = "Counts how many times the getRandomFighters method has been invoked")
    @Timed(name = "timeGetRandomFighters", description = "Times how long it takes to invoke the getRandomFighters method", unit = MetricUnits.MILLISECONDS)
    // end::adocMetrics[]
    // tag::adocTimeout[]
    @Timeout(250)
    // end::adocTimeout[]
    @GET
    @Path("/randomfighters")
    public Uni<Fighters> getRandomFighters() throws InterruptedException {
        // tag::adocTimeout[]
        veryLongProcess();
        // end::adocTimeout[]
        return service.findRandomFighters();
    }
    // end::adocFaultTolerance[]

    @Operation(summary = "Returns all the fights from the database")
    @APIResponse(responseCode = "200", content = @Content(mediaType = APPLICATION_JSON, schema = @Schema(implementation = Fight.class, type = SchemaType.ARRAY)))
    @APIResponse(responseCode = "204", description = "No fights")
    // tag::adocMetrics[]
    @Counted(name = "countGetAllFights", description = "Counts how many times the getAllFights method has been invoked")
    @Timed(name = "timeGetAllFights", description = "Times how long it takes to invoke the getAllFights method", unit = MetricUnits.MILLISECONDS)
    // end::adocMetrics[]
    @GET
    public Multi<Fight> getAllFights() {
        return service.findAllFights();
    }

    @Operation(summary = "Returns a fight for a given identifier")
    @APIResponse(responseCode = "200", content = @Content(mediaType = APPLICATION_JSON, schema = @Schema(implementation = Fight.class)))
    @APIResponse(responseCode = "204", description = "The fight is not found for a given identifier")
    // tag::adocMetrics[]
    @Counted(name = "countGetFight", description = "Counts how many times the getFight method has been invoked")
    @Timed(name = "timeGetFight", description = "Times how long it takes to invoke the getFight method", unit = MetricUnits.MILLISECONDS)
    // end::adocMetrics[]
    @GET
    @Path("/{id}")
    public Uni<Response> getFight(@Parameter(description = "Fight identifier", required = true) @PathParam("id") Long id) {
        Uni<Fight> fight = service.findFightById(id);
        return fight
            //.onItem().delayIt().by(Duration.ofMillis(100))
            .onItem().transform(item -> Response.ok(fight).build())
            .ifNoItem().after(ofSeconds(1)).recoverWithUni(Uni.createFrom().item(Response.noContent().build()))
            .onFailure().transform(failure -> new ServiceUnavailableException(failure.getMessage(), Response.serverError().build(), failure));
    }

    @Operation(summary = "Trigger a fight between two fighters")
    @APIResponse(responseCode = "200", description = "The result of the fight", content = @Content(mediaType = APPLICATION_JSON, schema = @Schema(implementation = Fight.class)))
    // tag::adocMetrics[]
    @Counted(name = "countFight", description = "Counts how many times the createFight method has been invoked")
    @Timed(name = "timeFight", description = "Times how long it takes to invoke the createFight method", unit = MetricUnits.MILLISECONDS)
    // end::adocMetrics[]
    @POST
    public Fight fight(@RequestBody(description = "The two fighters fighting", required = true, content = @Content(mediaType = APPLICATION_JSON, schema = @Schema(implementation = Fighters.class))) @Valid Fighters fighters, @Context UriInfo uriInfo) {
        return service.persistFight(fighters);
    }

    @GET
    @Produces(TEXT_PLAIN)
    @Path("/hello")
    public String hello() {
        return "hello";
    }
}
// end::adocResource[]
