# Introduction

This is a machine learning / genetic algorithms project I originally proposed [here](http://lesswrong.com/lw/iwa/replicating_douglas_lenats_traveller_tcs_win_with/), involving optimizing fleets for the science fiction roleplaying game Traveller. Historical background [here](http://aliciapatterson.org/stories/eurisko-computer-mind-its-own). The stats for Lenat's winning fleet can be found [here](http://members.pcug.org.au/~davidjw/tavspecs/best_tml/Starships%20(HG)%20-%20Professor%20Lenat%20and%20EURISKO's%20Winning%20Fleet.htm).

At the moment, I'm *mostly* done writing the game code, and expect to begin writing the machine learning part soon. Current TODOs:

1. Finish writing code for human players (may put this off, as its not the focus of the project)
2. Implement different options for energy weapons

## Rules Sources and Notes

The Trillion Credit Squadron scenario had special rules for calculating fleet costs. Among other things, the rules specify that players must pay:

>Architect's fees for the first ship of a specified class. Changes in a ship which do not constitute design of a new ship class do not require additional architect's fees. Changes in a design which alter its class require payment of architect's fees for the entire ship. Ship class is discussed on page 19.

>*(Source: Game Designers' Workshop. Adventure 5: Trillion Credit Squadron. p. 8.)*

On the other hand, the rules state that the following costs may be ignored:

> 1. Salaries for crew members.
> 2. Ship operating expenses, including fuel, environment, overhaul, and life support expenses.
> 3. Ammunition, including reloads, expendable items, missiles, and spare parts.
> 4. Ship's Locker, including aromory equipment for ship's troops or service crew, small arms, vacc suits, tools, and other minor items.
> 5. Battle damage repairs.

>*(Source: Game Designers' Workshop. Adventure 5: Trillion Credit Squadron. p. 8.)*

Fleets with multiple ships of the same also get a discount:

> When more than one vessel (ship, big craft, or small craft) is constructed using the same or similar statistics (see page 19), the second and all subsequent vessels are produced at 80% of the construction cost of the original vessel. The architect's fee need not be paid again.

>*(Source: Game Designers' Workshop. Adventure 5: Trillion Credit Squadron. p. 9.)*

Finally, I plan to write the code in a way that assumes the rules of the original 1981 tournament, which stated:

>Battle will be to the death: whichever player has the last ship capable of firing will be declared the winner of the round...

>...The maximum allowed tech level for all ships is 12. The total pilot allowance for the squadron is 200. The squadron must be capable of jump-3; each ship and small craft must be capable of 1-G acceleration. The squadron must be capable of gas giant refueling.

>*(Source: Game Designers' Workshop. Adventure 5: Trillion Credit Squadron. p. 30.)*

Most other important rules were found in Book 5: High Guard. 

# AI Design

Two AIs need to be written: an AI to design fleets, and an AI to play the actual game. The hard part of TCS seems to be fleet design, but the fleet design AI needs the player AI to run simulated battles, and flaws in the second AI may lead to fleets being tailored to its flaws, rather than an optimal fleet.

## Game AI

While decisions made playing the game may not be as complicated as fleet design decisions, it's still not entirely clear what the optimal strategy is. However, it seems likely that the best strategy would divide fire evenly among those ships still able to fight. 

All shots against a given ship must be declared before any are resolved, so concentrating fire on one ship risks wasting shots. Also, many damage effects either directly reduce a ship's effectiveness, or take it out of the fight entirely in a single shot. This is in contrast to other game systems, where units retain full combat effectiveness until they reach 0 hit points (a rule that greatly rewards concentrating fire). 

It is unclear how useful making repairs mid-combat is, so this will be reserved for ships not able to fight.

# Notes On Rules and Implementation Decisions

These notes are in large part for my own benefit, but in some cases document important decisions about how to interpret the game rules.

## Ship Stats Summary

The following stats are encoded in a ship's USP Code:

* Tonnage Code
* Configuration
* Jump
* Maneuver
* Power Plant
* Computer
* Crew
* Hull armor
* Sandcasters
* Meson screen
* Nuclear dampers
* Force field
* Repulsors
* Lasers
* Energy weapons
* Particle accelerator
* Meson gun
* Missiles
* Fighter squadrons

Other stats:

* Cost
* Battery bearing
* Battery count
* Tons (exact number)
* Crew (exact number)
* Agility
* Fuel (without drop tanks)
* Cargo
* "Low" (?)
* Marines
* Drop tanks

Most of these values may be set freely. Agility, battery bearing, cost, crew code, and tonnage code are calculated from other statistics. Effective drive and power plant ratings when using drop tanks also need to be calculated. Many other stats are to some degree constrained by other stats, but can't be directly calculated from them. 

## Drop Tanks

The rule quoted above stating that "the squadron must be capable of jump-3" refers to its capability for faster-than-light travel. This is an important rule, because in the rules of Traveller, faster-than-light travel requires a significant amount of fuel, equal to 10% of the ship's mass per jump number.

An interesting feature of [Lenat's winning fleet](http://members.pcug.org.au/~davidjw/tavspecs/best_tml/Starships%20(HG)%20-%20Professor%20Lenat%20and%20EURISKO's%20Winning%20Fleet.htm) is that all the ships (except fighters designed to be carried by larger ships) relied on external "drop tanks" in order to have enough fuel to be capable of faster-than-light travel. Without these tanks, all the non-fighters were officially stated to have jump numbers of 5, indicating 6% of their mass was taken up by their jump drives. Furthermore, in all these cases, the ships were intended to be used with drop tanks whose mass was equal to 50% of the main ship's mass. This reduced the size of the jump drive relative to the total mass of the ship + tanks to 4%, corresponding to the jump number of 3 required by the tournament rules, and meant that the tanks comprised 1/3 of that total mass, slightly more than the 30% (for a jump number of 3) required by the rules of Traveller.

Drop tanks would have been a significantly cheaper way to meet the fuel requirements for jumps because they only cost 10,000 credits + 1,000 credit per ton. In contrast, space within a ship's main hull costs tens of thousands of credits per ton (with the exact number depending on hull configuration). Drop tanks had considerable disadvantages to balance this reduced cost, but those disadvantages appear to have been ignored in the TCS tournament, making the ship design strategy used by Lenat/EURISKO clearly a winning one (though they could have gotten by with slightly smaller drop tanks). Therefore, one important test in the machine learning stage of this project will be to see if the algorithms can independently re-discover this strategy.

The advantages of using drop tanks are substantial enough on their own that I will assume they cannot be voluntarily jettisoned during combat, and that their mass still counts towards total ship mass after being destroyed in combat.

## Crew Requirements

Crew requirement rules seem rather needlessly complicated, given how little role the crew serves in the TCS scenario. Therefore, largely for my own benefit, I've tried to summarize the relevant rules below. Question marks indicate issues where the rules appear unclear to me.

### Small Craft

Small (military) craft are assumed to have a crew size of two: one pilot and one gunner.

### Non-Small Craft <= 1000 Tons

These ships must have a pilot and one gunner per turret (battery?). Ships of 200 tons or more must have a navigator and a medic, as well as one engineer per 35 tons of power plant.

### Craft > 1000 Tons

These ships will have at least three section heads requiring staterooms. If the ship has any launched craft, there will be a section head for the flight section. If the ship carries troops, the commander of the ship's troops counts as a section head for purposes of necessary crew quarters.

In terms of total crew, all ships over 1000 tons have will have a command section of at least six people (plus support personnel?—the rules are unclear). For ships over 20,000 tons, this increases to 5 crewmembers per 10,000 tons of ship (rounding?)

Engineering section will have one crewmember per 100 tons of drives. Gunnery section will have one crew per 100 tons of major weapon, two per bay weapon, one per turret battery, and four per screen. If the ship has launched craft, this requires one crewmember plus one per craft plus crew for craft.

## Ignored Rules

The rules for boarding and ship's troops seem highly unlikely to matter in the TCS scenario, and therefore will probably never be implemented:

The rule that sufficiently similar, but distinct, ship designs get a discount will not be implemented for now.

Because TCS rules specify that fights are to the death, the possibility of retreat will be ignored.

## Tech Levels

Because the original TCS tournament set the tech level at 12, I've focused on implementing rules for that tech level. Some systems are unavailable at that tech level, while others may be obsolete. So be warned: implementation of rules for unavailable or obsolete systems may be spotty. 

System factors that are available, but not obsolete, at TL12:

1. Particle Accelerator: 4, 8, E, L, Q
2. Meson Gun: C, D, K
3. Missile: 1-6, 8-9
4. Laser: 1-8
5. Energy Weapon: 1-8
6. Sand-Caster: 3-9
7. Repulsor: 6
8. Nuclear Dampers: 1
9. Meson Screens: 1
10. Jump Drives: 1-3
11. Computers: 1-6

## Missiles

It's unclear at what point in the ship design process players are supposed to choose whether to use high explosive or nuclear missiles. I've decided to make nuclear missiles the default, much as beam lasers are the default.

## "Relative Computer Size"

In Traveller, "relative computer size" modifies attack roles. However, it is somewhat unclear what this means. A natural interpretation would be that this represents the *difference* in computer size between the two ships involved. However, the *High Guard* rules say on p. 28 that, "Model number is the relative size of the computer, and corresponds to the computer model numbers given in Book 2. Model/1 is the standard computer model..." So perhaps "relative computer size" means relative to this "standard model." 

This ambiguity in the rules is important, because the first interpretation makes ships with good computers substantially harder to hit. I've decided to go with this first interpretation, because it seems to be the one assumed in various blog and forum posts I've read about the game, and because it makes it possible to make sense of Lenat's claim (quoted in the article linked at the beginning of this readme) that Eurisko had produced some almost unhittable ship designs.

## Gas Giant Refueling

Requirements for a ship's being able to refuel from gas giants can be found on *High Guard* p. 27 and *Trillion Credit Squadron* p. 39. Fuel scoop cost is negligible and will be ignored. Lenat's fleet design suggests that the rule requiring 10% of fuel tankage to be in streamlined or partially streamlined ships was in force in the TCS tournament. It is unclear whether rules for fuel refineries were used in the tournament, but tentatively they will be ignored.

## Energy Weapons

The situation with energy weapons is a little weird, because like missiles and lasers, they come in two flavors, in this case plasma guns and fusion guns. Unlike those other cases, though, the difference is not in the weapons' damage roll, but solely in their weight, energy requirements, and cost. Furthermore, there is some overlap between the factors of the bay and turret versions of those weapons.

A factor 4 energy weapon battery can be attained two ways: plasma gun turrets, or fusion gun turrets. In the first case, weight per battery is 8 tons, energy per battery is 4 EP, and cost per battery is 6 MCr. In the second case, weight per battery is 2 tons, energy per battery is 2 EP, and cost per battery is 2 EP. Hence, fusion guns are superior in every way.

A similar situation exists with factor 5 energy weapon batteries. The numbers are 20 tons vs 8 tons, 10 EP vs 8 EP, and 15 MCR vs. 8 MCr. Again, fusion guns are superior in every way.

At factor 6, there are three possibilities: turrets of either type, or bay plasma guns. Here are the numbers:

                   Weight   Energy  Cost  
Plasma gun turret: 32 tons  16 EP   24 MCr
Fusion gun turret: 20 tons  20 EP   20 MCr
Bay plasma gun:    50 tons  10 EP   5 MCr

At factor 7, there are again three possibilities: turrets of either type, or bay fusion guns. Here are the numbers:

                   Weight   Energy  Cost  
Plasma gun turret: 40 tons  20 EP   30 MCr
Fusion gun turret: 32 tons  32 EP   32 MCr
Bay fusion gun:    50 tons  20 EP   8 MCr

In neither case does one option completely dominate any of the others, making it necessary to make all three options available to ship designers.