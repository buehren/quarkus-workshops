// tag::adocResource[]
package io.quarkus.workshop.superheroes.villain;

// end::adocResource[]
import io.smallrye.mutiny.Multi;
import io.smallrye.mutiny.Uni;

import org.eclipse.microprofile.jwt.JsonWebToken;

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

import javax.annotation.security.PermitAll;
import javax.annotation.security.RolesAllowed;
import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.validation.Valid;
import javax.ws.rs.*;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.UriBuilder;
import javax.ws.rs.core.UriInfo;
import java.net.URI;

import static java.time.Duration.ofSeconds;
import static javax.ws.rs.core.MediaType.APPLICATION_JSON;
import static javax.ws.rs.core.MediaType.TEXT_PLAIN;


@Path("/api/villains")
@Produces(APPLICATION_JSON)
@RolesAllowed("**")
public class VillainResource {

    private static final Logger LOGGER = Logger.getLogger(VillainResource.class);

    @Inject
    @RequestScoped
    JsonWebToken jwt;

    @Inject
    VillainService service;

    @Operation(summary = "Returns a random villain")
    @APIResponse(responseCode = "200", content = @Content(mediaType = APPLICATION_JSON, schema = @Schema(implementation = Villain.class, required = true)))
    // tag::adocMetrics[]
    @Counted(name = "countGetRandomVillain", description = "Counts how many times the getRandomVillain method has been invoked")
    @Timed(name = "timeGetRandomVillain", description = "Times how long it takes to invoke the getRandomVillain method", unit = MetricUnits.MILLISECONDS)
    // end::adocMetrics[]
    @GET
    @Path("/random")
    public Uni<Villain> getRandomVillain() {
        LOGGER.info("getRandomVillain: Start. jwt="+jwt);

        Uni<Villain> villain = service.findRandomVillain();

        LOGGER.info("getRandomVillain: Returning villain: " + villain);
        return villain;
    }

    @Operation(summary = "Returns all the villains from the database")
    @APIResponse(responseCode = "200", content = @Content(mediaType = APPLICATION_JSON, schema = @Schema(implementation = Villain.class, type = SchemaType.ARRAY)))
    @APIResponse(responseCode = "204", description = "No villains")
    // tag::adocMetrics[]
    @Counted(name = "countGetAllVillains", description = "Counts how many times the getAllVillains method has been invoked")
    @Timed(name = "timeGetAllVillains", description = "Times how long it takes to invoke the getAllVillains method", unit = MetricUnits.MILLISECONDS)
    // end::adocMetrics[]
    @GET
    public Multi<Villain> getAllVillains() {
        return service.findAllVillains();
    }

    @Operation(summary = "Returns a villain for a given identifier")
    @APIResponse(responseCode = "200", content = @Content(mediaType = APPLICATION_JSON, schema = @Schema(implementation = Villain.class)))
    @APIResponse(responseCode = "204", description = "The villain is not found for a given identifier")
    // tag::adocMetrics[]
    @Counted(name = "countGetVillain", description = "Counts how many times the getVillain method has been invoked")
    @Timed(name = "timeGetVillain", description = "Times how long it takes to invoke the getVillain method", unit = MetricUnits.MILLISECONDS)
    // end::adocMetrics[]
    @GET
    @Path("/{id}")
    public Uni<Response> getVillain(@Parameter(description = "Villain identifier", required = true) @PathParam("id") String id) {
        return service
            .findVillainById(id)
            .map(item -> Response.ok(item).build())
            .ifNoItem().after(ofSeconds(1)).recoverWithUni(Uni.createFrom().item(Response.noContent().build()))
            .onFailure().transform(failure -> new ServiceUnavailableException(failure.getMessage(), Response.serverError().build(), failure));
    }

    @Operation(summary = "Creates a valid villain")
    @APIResponse(responseCode = "201", description = "The URI of the created villain", content = @Content(mediaType = APPLICATION_JSON, schema = @Schema(implementation = URI.class)))
    // tag::adocMetrics[]
    @Counted(name = "countCreateVillain", description = "Counts how many times the createVillain method has been invoked")
    @Timed(name = "timeCreateVillain", description = "Times how long it takes to invoke the createVillain method", unit = MetricUnits.MILLISECONDS)
    // end::adocMetrics[]
    @POST
    public Uni<Response> createVillain(@RequestBody(required = true, content = @Content(mediaType = APPLICATION_JSON, schema = @Schema(implementation = Villain.class)))  @Valid Villain villain, @Context UriInfo uriInfo) {
        return service.persistVillain(villain).chain( () -> {
            UriBuilder builder = uriInfo.getAbsolutePathBuilder().path(villain.id.toString());
            LOGGER.debug("New villain created with URI " + builder.build().toString());
            return Uni.createFrom().item(Response.created(builder.build()).build());
        });
    }

    @Operation(summary = "Updates an exiting  villain")
    @APIResponse(responseCode = "200", description = "The updated villain", content = @Content(mediaType = APPLICATION_JSON, schema = @Schema(implementation = Villain.class)))
    // tag::adocMetrics[]
    @Counted(name = "countUpdateVillain", description = "Counts how many times the updateVillain method has been invoked")
    @Timed(name = "timeUpdateVillain", description = "Times how long it takes to invoke the updateVillain method", unit = MetricUnits.MILLISECONDS)
    // end::adocMetrics[]
    @PUT
    public Uni<Villain> updateVillain(@RequestBody(required = true, content = @Content(mediaType = APPLICATION_JSON, schema = @Schema(implementation = Villain.class))) @Valid Villain villain) {
        return service.updateVillain(villain);
    }

    @Operation(summary = "Deletes an exiting villain")
    @APIResponse(responseCode = "204")
    // tag::adocMetrics[]
    @Counted(name = "countDeleteVillain", description = "Counts how many times the deleteVillain method has been invoked")
    @Timed(name = "timeDeleteVillain", description = "Times how long it takes to invoke the deleteVillain method", unit = MetricUnits.MILLISECONDS)
    // end::adocMetrics[]
    @DELETE
    @Path("/{id}")
    public Response deleteVillain(@Parameter(description = "Villain identifier", required = true) @PathParam("id") String id) {
        service.deleteVillain(id);
        LOGGER.debug("Villain will be deleted with " + id);
        return Response.noContent().build();
    }

    @GET
    @Produces(TEXT_PLAIN)
    @Path("/hello")
    @PermitAll
    public String hello() {
        return "hello";
    }
}
// end::adocResource[]
