# Introduction

This is a machine learning / genetic algorithms project I originally proposed [here](http://lesswrong.com/lw/iwa/replicating_douglas_lenats_traveller_tcs_win_with/), involving optimizing fleets for the science fiction roleplaying game Traveller.

I'm currently still in the "translate Traveller's rules into Ruby code" stage. The machine learning stage will come later.

I plan to write the code in a way that assumes the rules of the original 1981 tournament, which stated:

>Battle will be to the death: whichever player has the last ship capable of firing will be declared the winner of the round...

>...The maximum allowed tech level for all ships is 12. The total pilot allowance for the squadron is 200. The squadron must be capable of jump-3; each ship and small craft must be capable of 1-G acceleration. The squadron must be capable of gas giant refueling.

>*(Source: Game Designers' Workshop. Adventure 5: Trillion Credit Squadron. p. 30.)*

Most other important rules were found in Book 5: High Guard. 

# Ship Stats Summary

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

# Drop Tanks

The rule quoted above stating that "the squadron must be capable of jump-3" refers to its capability for faster-than-light travel. This is an important rule, because in the rules of Traveller, faster-than-light travel requires a significant amount of fuel, equal to 10% of the ship's mass per jump number.

An interesting feature of [Lenat's winning fleet](http://members.pcug.org.au/~davidjw/tavspecs/best_tml/Starships%20(HG)%20-%20Professor%20Lenat%20and%20EURISKO's%20Winning%20Fleet.htm) is that all the ships (except fighters designed to be carried by larger ships) relied on external "drop tanks" in order to have enough fuel to be capable of faster-than-light travel. Without these tanks, all the non-fighters were officially stated to have jump numbers of 5, indicating 6% of their mass was taken up by their jump drives. Furthermore, in all these cases, the ships were intended to be used with drop tanks whose mass was equal to 50% of the main ship's mass. This reduced the size of the jump drive relative to the total mass of the ship + tanks to 4%, corresponding to the jump number of 3 required by the tournament rules, and meant that the tanks comprised 1/3 of that total mass, slightly more than the 30% (for a jump number of 3) required by the rules of Traveller.

Drop tanks would have been a significantly cheaper way to meet the fuel requirements for jumps because they only cost 10,000 credits + 1,000 credit per ton. In contrast, space within a ship's main hull costs tens of thousands of credits per ton (with the exact number depending on hull configuration). Drop tanks had considerable disadvantages to balance this reduced cost, but those disadvantages appear to have been ignored in the TCS tournament, making the ship design strategy used by Lenat/EURISKO clearly a winning one (though they could have gotten by with slightly smaller drop tanks). Therefore, one important test in the machine learning stage of this project will be to see if the algorithms can independently re-discover this strategy.

The advantages of using drop tanks are substantial enough on their own that I will assume they cannot be voluntarily jettisoned during combat, and that their mass still counts towards total ship mass after being destroyed in combat.