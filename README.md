# Train Speed Limter

![icon](images/thumb.png)

[Mod Download](https://mods.factorio.com/mods/d3x0r/train-speed-limiter) 

[Forum thread](https://forums.factorio.com/viewtopic.php?f=91&t=51104)


Modifies train speeds based on track type used.  Extends JunkRails, Bio Industries and RailPowerSystem rails.

Modifies Standard locomotive(base), Junk Train(ScrapRails), Hybrid Train(RailPowerSystem), Nuclear locomotive, Angel's Petrochem train, FARL train(FARL), Electric Train locomotives, Fusion Locomotive, Yuoki Trains.


This is the table of modifiers used.

|   | Standard Rail | Water Crossing Rail | Scrap Rail | Concrete Rail |
|:---|:---:|:---:|:---:|:---:|
| Multiplier | 0.995  | 0.9925 | 0.989 | 0.9965 |
| Percentage | -0.5%   | -0.75% | -1.1% | -0.35% |
| Max Speed(unused?)  | 360 | 280  | 95  | 720  |

## Standard Diesel Locomotive Trains
### Without modification
| Wood/Coal | Solid Fuel | Rocket Fuel |
|:------:|:---:|:---:|
| 259.1 | 272.2 | 298.1 |

### With Mod

  - Increase max speed from 259.2 to 863
  - Increase power from 600kW to 1200kW
  - Increase efficiency from 1.0 to 1.5 
  - Increase air resistance from 0.75% to 0.8%

| Track Type | Wood/Coal | Solid Fuel | Rocket Fuel |
|:--------|:------:|:---:|:---:|
| Scrap | 110 | 115.7 | 123 |
| Water | 120? | 145.4? | 221.2? |
| Standard | 233 | 257.5 |  293.4 |
| Concrete | 279 | 308 |  352 |

## Junk Train (Junk Train mod)
### without Modification
| Wood/Coal | Solid Fuel | Rocket Fuel |
|:------:|:---:|:---:|
| 31.9 |  ?? | 60.4 |

### With Mod

  - Increase max speed from 64.8 to 256.2
  - Increase power form 300kW to 750kW
  - Increase air resistance from 3% to 5% (to get back up to normal speed on scrap rail)
  - Increase burner effectivity from 0.3 to 1.5 ( still burns fuel pretty fast for distance covered)

|Track Type| Wood/Coal | Solid Fuel | Rocket Fuel |
|:----- |:------:|:---:|:---:|
| Scrap | 33.2 | 36.4  | 41.6 |
| Water | 40.2 | 44.4 | 50 |
| Standard | 40.8 | 45 |  51.4 |
| Concrete | 43.2 | 47.9 | 54.6 |

## Hybrid Train (Rail Power System mod)
### without Modification
| Electricity |
|:------:|
| 259.2 |

### With Mod
  - Add powered wood bridge rails (if also have Bio Industries for graphics)
  - Add powered concrete rails (if also have Bio Industries for graphics) 
  - Increase power from 600kW to 1750kW
  - Increase max speed from 259.2 to 863
  - Increase air resitance form 0.75% to 1.2%
  - Increase rail accumulator storage from 11kJ to 30kJ (to support higher power)

|Track Type | Electricity |
|:------|:------:|
|Scrap    | N/A |
|Water    | 293 |
|Standard | 280 |  * only standard rails are modified with electric power
|Cemeent  | 324 |

## Nuclear Locomotive (Nuclear Locomotives Mod)
### without Modification

| Uranium |
|:------:|
| 324 |

### With Mod

  - Increase power from 1200kW to 2400kW
  - Increase max speed from 324 to 863
  - Increase air resistance from 0.75% to 1.0%


| Track Type | Uranium |
|:------|:------:|
|Scrap    | 115 |
|Water    | 296 |
|Standard | 284 |
|Concrete   | 355 |


## Summary of Locomotive Changes

Standard locomotives have higher speeds in some conditions, but take a long time to get up to speed. 

Hybrid and Nuclear locomotives, increased acceleration, so they get up to higher speeds faster at a slight increase in power requirement.

Junk train locomotive had to have lowered air resistance so it could approach the same speeds on junk rails.

## Fuel Modifications

Original trains are mostly limited by their max_speed setting; and therefore the fuel modifier of top_speed_multiplier affects
their top end speed.  Solid fuel has a top speed multiplier of 1.05, rocket fuel has a top speed multiplier of 1.15.  Becuase train
max speed is now basically uncapped, this multiplier needs to be expressed as an acceleration modifier instead.

  * Solid Fuel
    * Decrease acceleration modifer from 1.2 to 1.1

  * Rocket Fuel
    * Decrease acceleration modifier form 1.8 to 1.25


## Existing Issues

Rail Power System mod requires updates to allow me to connect to cement and bridge rails.  A work-around is to connect a segment of standard
powered rail to cement or bridge rails and use that to connect a rail power pole.  Also, the internal max power transfer for hybrid trains
is hard coded to a small value, so new trains will be limited in speed, unable to draw the full 1500kW power from the rails.

Cargo Wagon max speeds are left un modified; this may limit trains more than they should.

## Changelog
0.0.702
   - fix compatibilty with RPS 0.1.4 so I don't REQUIRE update to that.
   - add optional mod dependancies
   - increase cargo-wagon and fluid-wagon max_speed

0.0.701
  - rebalance rail modifiers so they're all less than 1
  - rebalance train performance for all rails being a penalty
  - rebalance fuel type bonuses to acheive effective max speed bonus
  - add FARL compatibility modification (untested balance)
  - add Electric Trains compatibility (untested balance)
  - add Fusion Locomotive compatibilty (untested balance)
  - add Yuoki Industries - Railroads compatibility (untested balance)
  - add YIR - Uranium Power Trains compatiblity (untested balance)
  - add YIR - Youki Industry Railroads compatiblity (untested balance)

0.0.5  
  - fix bridge power rails. 
  - Fix placing power poles to power new cement and bridge types. 
  - Add update accumulators already on the map to the new required value
  - add a bridge rail accumulator for placing powered bridge rails.
  - tweaked junk train settings a little to make it a hair faster; normal player walk speed is 32kph, and the reduced value (30kph) I decided was
too slow; so increased it to 33.1kph.

0.0.4
  - improved optional mod dependancy behavior; only define rail types to track based on which mods had been loaded.


