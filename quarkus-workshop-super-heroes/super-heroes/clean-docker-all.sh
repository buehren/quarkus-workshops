#!/bin/sh

sudo docker container rm super-heroes_quarkus-workshop-fight_1 super-heroes_quarkus-workshop-villain_1 super-heroes_quarkus-workshop-stats_1 super-heroes_quarkus-workshop-hero_1

sudo docker image rm tbuehren/quarkus-workshop-fight  tbuehren/quarkus-workshop-stats  tbuehren/quarkus-workshop-villain  tbuehren/quarkus-workshop-hero

sudo docker image prune
