Going to try having all values in ship genomes normalized from 0 to 1.

For weapons/batteries, count is always 0 if the factor is, 1 if the factor is A or above, and can range from 1 to 33 otherwise. This last case requires the 0 to 1 range partitioned into 33 segments.

* Particle Accelerator: six possible factors (0, 4, 8, E, L, Q), so proceeds in sixths
* Meson Gun: four possibilities (0, C, D, K) so proceeds in fourths.
* Missile: nine possible factors (0-6, 8-9). Additional binary choice of nuclear or conventional missiles.
* Laser: A binary choice of type determines the range of options: nine options (0-8) for beam lasers and seven options (0-6) for pulse lasers.
* Energy Weapon: Six options, 0 plus 3-7. A binary choice of type adds one to the factor if the type is fusion gun
* Sand-Caster: eight possibilities (0, 3-9)
* Repulsor: binary choice (0, 6)

Non-weapons tech:

* Nuclear Damper: binary choice (0, 1); count limited to 1
* Meson Screen: as Nuclear Damper
* Jump Drive: should really be a binary choice of 0 or 3
* Computers: Can't be 0 on fighting ships. 1-6 regular or fiberoptic, 1 or 2 bis.
* Power plant: 1 to 50
* Maneuver 1 to 6
* Armor: 0 to Z, with some constraints based on hull config

Vehicles: ??? (This is a really complicated thing to handle)

Tonnage: Tonnage code can range over 33 possible values, from 0 to Y. Within that range, can have between 0 and 99% of difference between that tonnage code and the next highest one, rounded to the nearest percent. No ship can be 0 tons. Tonnage code Y ships are assumed to be between 1,000,000 and 1,990,000 tons.

Configuration: 9 possible values

TODO: Drop tanks, crew, fuel, check standard ship types for anything you forgot