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

Some uses of land (e.g., building apartments) require that the land be zoned appropriately. Players can lobby using Political Capital for zoning changes that enable them to do what they want, and can also lobby against others' proposed changes. [Vilas County's zoning regulations](http://www.vilascountyzoning.com/forms/Zoning%20District%20Use%20Table.pdf) are very loose, so zoning is only a minor impediment to changes to the landscape. *All players gain two Political Capital points per turn*, but these *expire after 3 turns*. Some player actions can generate more Political Capital. In the case of a zoning dispute, the state (i.e., the game) will take whatever action has the most Political Capital committed. 

Non-Player Characters
=====================
NPCs are also present in the game world, and are meant to represent a variety of different perspectives.
We need to create NPC agents for:
* **Farmers** - Farming parcels, competing for land use
* **Bird watchers** - Complain when important birds have their habitat reduced. They will donate money to Conservationists that are improving bird habitability of the world (e.g., if bird quest achievement obtained). They may even lobby against zoning changes that would interfere.
* **Hunters** 

NPCs communicate to players by sending messages to them ("You received a letter from the Vilas Marten Lovers Association..."). They may also buy land and lobby for/against zoning changes (e.g., to farm land).


Player Abilities
================
Every player's moves are about how to shape the landscape or participate in the economic system of the game. All roles have some common abilities, but each has role specific capabilities, constraints, and goals. No player has perfect information about the state of any part of the landscape, and must acquire survey data to get detailed information about places of interest to them. 

All players can commission a survey of a parcel of land, and all can submit bids to buy land, as well as accept bids to sell land that they already own. All players can hire crews and buy equipment, though the particulars of what staff/equipment they can acquire differ by role.

Timber Company Abilities
------------------------
Timber Companies have the unique ability to harvest trees and sell them at market for money, as well as the ability to plant saplings.

Timber Cos can enact several different harvest strategies: 
* **Clearcut** - Removes all trees from a tile. 
* [**Arbogast Cut**](http://www.metla.fi/silvafennica/full/sf34/sf343223.pdf) (also known as BDq) - Removes a sampling of trees from a tile across a range of sizes, using a q-ratio to determine how many trees of each size to cut, relative to the next larger size. 
* **Diameter Limit Cut** - Cuts all trees above a given size threshold (e.g., cut all trees larger than 16in diameter). 

These different cuts offer the opportunity to enact different growth and harvest strategies, which may be needed to achieve certain player goals. For example, if the player only wants to sell large trees, then the diameter limit may be appropriate.

The Timber Company can either harvest from its own land, or get contracts to harvest from another's land. These contracts may require the player to give a percentage of earnings to the land owner. 

The Timber Company's ability to harvest trees is determined by its progress on the Timber Co Tech Tree. Progress on the tech tree gives the player the ability to harvest more quickly, over a larger area, or using more complex cutting strategies (e.g., the BDq cut requires more skill due to its need of careful measurement and sampling). 

Timber Companies that have significantly advanced on the tech tree (by Hiring Foresters) may obtain their own survey data without need for a Conservation player to assist. In addition to the cost/requirements of each Forester hired, the cost to a Timber Company of surveying is higher (let's say 30%) than if a Conservationist did the survey, but doing so does not send money to the Conservationist.

Developer Abilities
-------------------
Developers have the unique ability to create buildings. For now this ability is restricted to homes and parks, but this could conceivably later include commercial/industrial facilities, such as mills. 

Developers can build homes at different sizes and densities, ranging from secluded luxury cabins to dense apartment buildings. These properties generate revenue as long as they are owned and occupied, but also cost annual upkeep. Occupancy is determined by the simulation, which moves the county's population around annually to the most desirable places to live. 

The developer's building activities can increase the market value of timber, which can make the Timber Companies richer, but also increase the cost of building.
 
The Developers actions are:
* **Build homes** - Multiple types available are: hotels, luxury vacation homes, vacation condos. These have different levels of density/capacity and size. 
* **Build parks** - This is either upon request by a conservationist, or must immediately be donated to a conservationist player. If for donation, then the developer immediately 10 Political Capital points.
* **Bulldoze parcels** - A resource tile must be cleared before it can be built on. This can be done by bulldozing, or by giving a Timber Company access to clearcut the land. Bulldozing is faster, but doesn't generate revenue from the forest product value. Bulldozing clears everything on the tile, including destroying any animal or plant life. 

The annual rent that the developer receives is a function of the occupation rate of the housing he/she has built, and the desirability of the occupied properties. Desirability is inversely related to population density, and directly related to ecological health of the property's surroundings. More desirable properties are more likely to get rented, but are also likely to house fewer people. 

The developer should make careful use of survey data to avoid building in places that contain endangered species. Massive political capital and financial penalties apply. However, if a developer discovers such a critter and donates the land to a conservationist, s/he gets lots of political capital.


Conservation Nonprofits
-----------------------
Conservation Nonprofits (or Conservationists) have the ability to 
* Survey land for detailed data about plant and animal species 
* Reintroduce animal species
* Plant trees - *all species or just some?*
* Build and operate parks for revenue. 

Conservation groups generate revenue by generating survey data for others, or by receiving donations. It costs a Conservationist considerably less to do a survey than it does a Timber Company. 

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
[Timber Company Cutting Technology]

Timber Companies may also plant new saplings to replace felled trees. 

Timber Companies can develop survey capacity by hiring Foresters (costs 15% more than it does for the Conservationist). This is identical to the Conservationist's survey ability (see below), but costs more (let's start with 20%) and does not send revenue to the Conservationists. Hiring a Forester also unlocks the Arbogast cut. 

### Yarding Upgrades
Each of these has an impact on the area harvested. This impact kills a proportionate amount of small plants/trees and animals in the area.  

1. **Horse Team** - The player has a borrowed horse team (from his Grandfather) for 8 years.
2. **Skidder** 
3. **Forwarder**

| Technology | Cost Year 1 | Upkeep/year |   Capacity  | Impact |  
| :--------: | :---------: | :---------: | :---------: | :----: |  
| Horse Team |   $60,000   |   $20,000   |  1 acre/day |    1   |  
|  Skidder   |   $120,000  |   $30,000   | 4 acres/day |    3   |  
| Forwarder  |   $200,000  |   $60,000   | 8 acres/day |    5   |  
[Timber Company Yarding Technology]

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
[Timber Company Transportation Technology]

Housing Developer Tech Tree
---------------------------
**Need help from Steve here**:
rates of activity - how long to complete a development project of each type? to grow as a business? some acres/year as reasonable approx?
Process of development - steps, tools, factors involved.


Conservation Nonprofit Tech Tree
--------------------------------
Conservationists become able to better protect the environment by hiring Foresters, recruiting volunteers, and building outposts and parks.

### Staffing Upgrades 
1. [**Forester**](http://en.wikipedia.org/wiki/Forester) - Necessary to do any of the Conservationist's actions. A Forester can survey up to 8 acres per day. Player starts with one but can hire more. Cost is $60k/year.
2. **Volunteer** - Each volunteer can augment a Forester's survey range by 1 acres/day. A Forester can only supervise 6 volunteers. First year cost to train a volunteer is $5k. Having volunteers increases the donation rate to the Conservationist.

### Intertubes
1. **Web Site** - Enables the Conservationist to share its mission with the public. Increases donation rate if the player is doing well, decreases it if doing poorly.
2. **Citizen Science** - Requires the Web Site upgrade. Enables the public to report data about plants or animals the the Conservationist cares about, e.g., endangered animal sightings. This can enable the Conservationist to make smarter decisions about land to protect. 

### Buildings
1. **Outpost** - Enables the conservationist to get free survey data about a megatile tile and its immediate neighbors, as long as the player has at least two foresters. Cost is $200k to build, and $100k/year. 
2. **Park** - An outpost can be converted in to a natural park. This protects the tile's neighbors from others' purchase, increases donations (admissions fees), but also has a negative impact on the land (e.g, people taking wood turtles as pets). This action requires a paid contract with a Developer. Developers can also donate parks to a conservationist, which yields 10 Political Capital points. 

Quests
======

Timber Company Quests
---------------------
These numbers will require some fiddling.

### Getting Started ###
The player must harvest at least 100 (reasonable??) marketable logs. 
This requires the player to survey some land to find suitable locations to buy (or lease access) then harvest.
The numbers in this quest should be tweaked to make the You're On Your Own quest doable.

### You're On Your Own ###
Grandpa congratulates you on getting started, but needs his horse crew back. The horses are getting old and it's time for you to learn how hard keeping a team employed is for a small business owner.
Player must hire a horse crew, then harvest another 100 logs.

### Big Stick ###
Harvest 1000 logs.

### Room To Grow ###
Buy 200 acres.

### Eco Friendly ###
Build a sustainable harvest operation that markets 10,000 logs year for 20 years. 

Conservationist Quests
----------------------

Developer Quests
----------------



