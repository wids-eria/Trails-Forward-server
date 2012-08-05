Overview
========
Trails Forward (TF) is a manyplayer role playing game in a shared, persistent simulation of Vilas County, WI. Eventually the game will take place over the historical arc of European settlement of the county, allowing the player to start in the mid 19th Century and shape the county's development to the present day. This gives players the ability to investigate the causes of why the world they help shape does or does not resemble present-day Vilas. For now, game play will begin in contemporary Vilas (circa 2000), and play forward from there.

Players choose one of three roles, the Timber Company, the Housing Developer, or the Conservation Nonprofit. Each of these roles offers a variety of achievements that the player can try to get. Those achievements require the player to achieve specific goals within the game world. These goals may be about a single player's accomplishments, or a shared world-level outcome. 

TF has Fantasy Sports-like timing, so the simulation is paused during the day, and ticks forward several years at night. This gives players to talk, trade, and evaluate possible moves during the day. Each turn (i.e., day; we can adjust this timing based upon player feedback) of play is four game-years. Some (beginner) achievements are for goals that a player can execute within very few turns (1-2), while others will require 50 game-years of play (13+ turns).

The Landscape
=============
Vilas County is approximately a million acres in size. TF simulates the development of the natural landscape by simulating changes to each of these acres (e.g., tree growth) over time. It also simulates the populations of different animals as they grow, die, and move. Players are dependent upon the landscape's dynamics to achieve their goals, such as the patterns of tree succession necessary to grow hardwoods, or the preservation of specific habitat characteristics necessary for the survival of particular animal species (e.g., the American Marten). 

Each acre has properties describing its characteristics, such as whether it is land or water (as in a lake), the number of trees at a range of different diameter sizes (2in to 24in in 2in incremements), and housing density. Different animal populations are simulated using an agent-based model that simulates each critter independently, according to species-specific decision rules. However, the population of extremely common, high quantity animals that are not central to game story (e.g., voles) is computed mathematically (such as through systems of differential equations), rather than through discrete agent-based simulation. Every critter has a discrete location in the world, and so each acre has a count of how many critters of each species is present on it. 

Saleable parcels of the landscape are exclusively 3x3 acres, though each square acre can be operated on (e.g., clearcut) individually by the player.


Player Abilities
================
Every player's moves are about how to shape the landscape or participate in the economic system of the game. All roles have some common abilities, but each has role specific capabilities, constraints, and goals. No player has perfect information about the state of any part of the landscape, and must acquire survey data to get detailed information about places of interest to them. 

All players can commission a survey of a parcel of land, and all can submit bids to buy land, as well as accept bids to sell land that they already own. All players can hire crews and buy equipment, though the particulars of what staff/equipment they can acquire differ by role.

Timber Company Abilities
------------------------
Timber Companies have the unique ability to harvest trees and sell them at market for money, as well as the ability to plant saplings.

Timber Cos can enact several different harvest strategies: Clearcut, an Arbogast Cut, and Diameter Limit Cut. Clearcut removes all trees from a tile. The Arbogast Cut (also known as BDq) removes a sampling of trees from a tile across a range of sizes, using a q-ratio to determine how many trees of each size to cut, relative to the next larger size (see: http://www.metla.fi/silvafennica/full/sf34/sf343223.pdf). The Diameter Limit Cut cuts all trees above a given size threshold (e.g., cut all trees larger than 16in diameter). These different cuts offer the opportunity to enact different growth and harvest strategies, which may be needed to achieve certain player goals. For example, if the player only wants to sell large trees, then the diameter limit may be appropriate.

The Timber Company's ability to harvest trees is determined by its progress on the Timber Co Tech Tree. Progress on the tech tree gives the player the ability to harvest more quickly, over a larger area, or using more complex cutting strategies (e.g., the BDq cut requires more skill due to its need of careful measurement and sampling). 

Timber Companies that have significantly advanced on the tech tree (by Hiring Foresters) may obtain their own survey data without need for a Conservation player to assist. In addition to the cost/requirements of each Forester hired, the cost to a Timber Company of surveying is higher (let's say 30%) than if a Conservationist did the survey, but doing so does not send money to the Conservationist.

Developer Abilities
-------------------
Developers have the unique ability to create buildings. For now this ability is restricted to homes, but this could conceivably later include commercial/industrial facilities, such as mills. 

Developers can build homes at different sizes and densities, ranging from secluded luxury cabins to dense apartment buildings. These properties generate revenue as long as they are owned and occupied, but also cost annual upkeep. Occupancy is determined by the simulation, which moves the county's population around annually to the most desirable places to live. 

Conservation Nonprofits
-----------------------
Conservation Nonprofits (or Conservationists) have the ability to survey land for detailed data about plant and animal species, to reintroduce animal species, to plant trees, and to build and operate parks for revenue. Conservation groups generate revenue by generating survey data for others, or by receiving donations. It costs a Conservationist considerably less to do a survey than it does a Timber Company. 

Tech Trees
==========
Each player can advance his/her capabilities by buying equipment or hiring staff/getting volunteers. 

Timber Company Tech Tree
------------------------
Timber Companies must have the capacity for cutting, yarding, and transportation. Cutting refers to actually cutting trees down, and includes both felling (chopping the tree down) and bucking (cutting it into logs). Yarding is the transportation of felled trees from where they are cut down to a staging area, where they can be loaded on trucks. Transportation refers to the ability to get yarded trees to a mill. 

### Cutting Upgrades
1. **Sawyer crew** - Many of these can be hired. Each crew (5 people) can fell and bunch 2 acres/day with no size limit. The player starts with one of these. 
2. [**Feller**](http://www.baucm.com/data/files/store_51/goods_10/small_200908270300107170.jpg) - Many of these can be purchased. Each can cut 4 acres per day, but *cannot buck*, so a Sawyer Crew must accompany the machine. This machine is only suitable for trees 8" in diameter or smaller.
3. [**Harvester**](http://www.baucm.com/data/files/store_51/goods_55/small_200908270254151682.jpg) - Many of these expensive machines can be purchased, and each can fell and buck 8 acres per day, with no size limit. This machine is slower in smaller trees, so might be used in combination with a Feller and Sawyer Crew for more efficient operation.

|   Technology   | Cost Year 1 | Upkeep/year |   Cut Rate  | Size Limit |       Limitations       |  
| :------------: | :---------: | :---------: | :---------: | :--------: | :---------------------: |  
|  Sawyer Crew   |   $120,000  |   $100,000  | 2 acres/day |            |                         |  
| Feller/Buncher |   $150,000  |   $40,000   | 4 acres/day | 8" or less |        no bucking       |  
|   Harvester    |   $500,000  |   $80,000   | 8 acres/day |            | slower in smaller trees |  
[Timber Company Cutting Technology][tech-tree-timber-cutting] 

Timber Companies may also plant new saplings to replace felled trees. 

Timber Companies can develop survey capacity by hiring Foresters. This is identical to the Conservationist's survey ability (see below), but costs more (let's start with 30%) and does not send revenue to the Conservationists. Hiring a Forester also unlocks the Arbogast cut. 

### Yarding Upgrades
Each of these has an impact on the area harvested. This impact kills a proportionate amount of small plants/trees and animals in the area.  

1. **Horse Team** - The player starts with one of these.
2. **Skidder** 
3. **Forwarder**

| Technology | Cost Year 1 | Upkeep/year |   Capacity  | Impact |  
| :--------: | :---------: | :---------: | :---------: | :----: |  
| Horse Team |   $60,000   |   $20,000   |  1 acre/day |    1   |  
|  Skidder   |   $120,000  |   $30,000   | 4 acres/day |    3   |  
| Forwarder  |   $200,000  |   $60,000   | 8 acres/day |    5   |  
[Timber Company Yarding Technology][tech-tree-timber-yarding]

### Transportation Upgrades
These need to be fleshed out more, but here are two to start with.

1. **Pick up truck** - The player starts with one of these and cannot buy another.
2. **Loader** 
3. **Logging Truck** 

|  Technology   | Cost Year 1 | Upkeep/year |   Capacity   |  
| :-----------: | :---------: | :---------: | :----------: |  
| Pickup Truck  |             |    $5,000   |  1 acre/day  |  
|    Loader     |   $120,000  |   $40,000   |  8 acres/day |  
| Logging Truck |   $200,000  |   $100,000  | 16 acres/day |  
[Timber Company Transportation Technology][tech-tree-timber-transportation]


