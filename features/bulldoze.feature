Feature: Bulldoze a Resource Tile
  Players should be able to bulldoze resource tiles that they own.

  Scenario: Bulldoze a megatile owned by the user
    Given I have a world
      And I have one user "riley@example.com" with password "letmein"
      And I have a player in the world
      And I own a megatile in the world
    When I bulldoze a resource tile on the megatile that I own
    Then that megatile should be empty

  Scenario: Bulldoze a megatile NOT owned by the user
    Given I have a world
      And I have one user "riley@example.com" with password "letmein"
      And I have a player in the world
      And I have an owned megatile in the world
    When I bulldoze a resource tile on the owned megatile Then I should get an error

  Scenario: Bulldoze a list of megatiles owned by the user
    Given I have a world
      And I have one user "riley@example.com" with password "letmein"
      And I have a player in the world
      And I own a megatile in the world
    When I bulldoze a list containing that resource tile on the megatile that I own
    Then the list containing that megatile should be empty

  Scenario: Bulldoze a list megatile where at least one is NOT owned by the user
    Given I have a world
      And I have one user "riley@example.com" with password "letmein"
      And I have a player in the world
      And I have an owned megatile in the world
    When I bulldoze a list containing that resource tile on the owned megatile Then I should get an error
