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
* Computers: 1-6, can't be 0 on fighting ships

Tech options:

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