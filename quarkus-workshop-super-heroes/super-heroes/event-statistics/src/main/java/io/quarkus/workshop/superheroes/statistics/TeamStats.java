package io.quarkus.workshop.superheroes.statistics;

import org.jboss.logging.Logger;

class TeamStats {

    private static final Logger LOGGER = Logger.getLogger(TeamStats.class);

    private int villains = 0;
    private int heroes = 0;

    double add(FightResult result) {
        LOGGER.info("TeamStats.add(FightResult)");
        if (result.getWinnerTeam()!=null) {
            if (result.getWinnerTeam().equalsIgnoreCase("heroes")) {
                heroes = heroes + 1;
            } else {
                villains = villains + 1;
            }
        }
        if (heroes + villains != 0) {
            return ((double) heroes / (heroes + villains));
        } else  {
            return 0.5;
        }
    }

}
