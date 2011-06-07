Feature: Clearcut a Resource Tile
	Players should be able to clearcut resource tiles that they own.

	Scenario: Clearcut a resource tile owned by the user
    Given I have a world
    	And I have one user "riley@example.com" with password "letmein"
    	And I have a player in the world
    	And I own a megatile in the world
		And my megatile is completely zoned for logging
    When I clearcut a resource tile on the megatile that I own
    Then that resource tile should have no trees
		And my bank balance should increase 

	# Scenario: Bulldoze a megatile NOT owned by the user
	#     Given I have a world
	#     	And I have one user "riley@example.com" with password "letmein"
	#     	And I have a player in the world
	#     	Given I have an owned megatile in the world
	#     When I bulldoze a resource tile on the owned megatile Then I should get an error
