Feature: User create a player in a world
  Users should be able to join a world once if that player type is available

  Scenario: Join world with no players
    Given I have a world with no players
      And I have a user
     When I create a developer in the world
     Then That player will be assigned to me

  Scenario: Join world with developer

  Scenario: Join world I have a player in already
