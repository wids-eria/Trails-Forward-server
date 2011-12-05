Feature: See bids placed
  Players should be able to see bids they have placed or received

  Scenario: See bids placed
    Given I have a world
      And I have one user "riley@example.com" with password "letmein"
      And I have a player in the world
      And I have an unowned megatile in the world
    When I bid 42 on the unowned megatile
    Then I should get a bid id
      And I should see that I have placed that bid

  Scenario: See bids received
    Given I have a world
      And I have one user "riley@example.com" with password "letmein"
      And I have a player in the world
      And I own a megatile in the world
      And a bid has been placed on that owned megatile
    Then I should see that I have received that bid
