Feature: Appraise a MegaTile
  Players should be able to appraise megatiles that they own.

  Scenario: Appraise a megatile owned by the user
    Given I have a world
      And I have one user "riley@example.com" with password "letmein"
      And I have a player in the world
      And I own a megatile in the world
      And at least one resource tile on the megatile is a land type
    When I appraise a megatile that I own
    Then the estimated value for the megatile should be greater than zero


  Scenario: Appraise a megatile NOT owned by the user
    Given I have a world
      And I have one user "riley@example.com" with password "letmein"
      And I have a player in the world
      And I have an owned megatile in the world
      And at least one resource tile on the owned megatile is a land type
    # When I appraise the megatile on the owned megatile Then I should get an error
    When I appraise the megatile on the owned megatile
    Then the estimated value for the megatile should be greater than zero

  Scenario: Appraise a list of megatile owned by the user
    Given I have a world
      And I have one user "riley@example.com" with password "letmein"
      And I have a player in the world
      And I own a megatile in the world
      And at least one resource tile on the megatile is a land type
    When I appraise a list containing the megatile that I own
    Then the estimated value for the list of megatile should be greater than zero

  Scenario: Appraise a list of megatile NOT owned by the user
    Given I have a world
      And I have one user "riley@example.com" with password "letmein"
      And I have a player in the world
      And I have an owned megatile in the world
      And at least one resource tile on the owned megatile is a land type
    # When I appraise a list containing that megatile on the owned megatile Then I should get an error
    When I appraise a list containing that megatile on the owned megatile
    Then the estimated value for the list of megatile should be greater than zero
