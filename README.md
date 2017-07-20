# Train Speed Limter

![icon](images/thumb.png)

[Mod Download](https://mods.factorio.com/mods/d3x0r/train-speed-limiter) 

[Forum thread](https://forums.factorio.com/viewtopic.php?f=91&t=51104)


Limit trains based on track type they are on.  This is the table of modifiers used.

|   | Standard Rail | Water Crossing Rail | Scrap Rail | Cement Rail |
|:---|:---:|:---:|:---:|:---:|
| Multiplier | 1.0  | 0.9975 | 0.992 | 1.0005 |
| Percentage | 0%   | -0.25% | -0.8% | +0.05% |
| Max Speed(unused?)  | 80  | 280  | 360  | 720  |

## Standard Diesel Locomotive Trains
### Without modification
| Wood/Coal | Solid Fuel | Rocket Fuel |
|:------:|:---:|:---:|
| 259.1 | 272.2 | 298.1 |

### With Mod

  - Increase max speed from 259.2 to 863
  - Increase air resistance from 0.75% to 1.2%

| Track Type | Wood/Coal | Solid Fuel | Rocket Fuel |
|:--------|:------:|:---:|:---:|
| Scrap | 73 | 88.5 | 134 |
| Water | 120 | 145.4 | 221.2 |
| Standard | 169 | 205 |  302-312 |
| Cement | 184 | 220 |  340 |

## Junk Train (Junk Train mod)
### without Modification
| Wood/Coal | Solid Fuel | Rocket Fuel |
|:------:|:---:|:---:|
| 31.9 |  | 60.4 |

### With Mod

  - Increase max speed from 64.8 to 256.2
  - Decrease air resistance from 3% to 1.2%

|Track Type| Wood/Coal | Solid Fuel | Rocket Fuel |
|:----- |:------:|:---:|:---:|
| Scrap | 30.0 | | 57 |
| Water | ?? | ?? | ?? |
| Standard | 80 | 120 |  152 |
| Cement | ?? | ?? | ?? |

## Hybrid Train (Rail Power System mod)
### without Modification
| Electricity |
|:------:|
| 259.2 |

### With Mod

  - Increase power from 600kW to 1500kW
  - Increase max speed from 259.2 to 863
  - Increase air resitance form 0.75% to 2%
  - Increase rail accumulator storage from 11kJ to 25kJ (to support higher power)

|Track Type | Electricity |
|:------|:------:|
|Scrap    | 146 |
|Water    | 209 |
|Standard | 261 .9 |  * only standard rails are modified with electric power
|Cemeent  | 275 |

## Nuclear Locomotive (Nuclear Locomotives Mod)
### without Modification

| Uranium |
|:------:|
| 324 |

### With Mod

  - Increase power from 1200kW to 1800kW
  - Increase max speed from 324 to 863
  - Increase air resistance from 0.75% to 1.9%


| Track Type | Uranium |
|:------|:------:|
|Scrap    | 127 |
|Water    | 218 |
|Standard | 332 |
|Cement   | 360-372 |


## Summary of Locomotive Changes

Standard locomotives remain the same.  They have higher speeds in some conditions, but take a long time to get up to speed. 
Some of the numbers reflect effective max speed and real max speed; depending on the length of rail it may not reach the specified speed.

Hybrid and Nuclear locomotives, increased acceleration, so they get up to higher speeds faster at a slight increase in power requirement.

Junk train locomotive had to have lowered air resistance so it could approach the same speeds on junk rails.



