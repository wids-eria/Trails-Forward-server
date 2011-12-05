Feature: Bid on a megatile
  Players should be able to see listings

  Scenario: See a listing for a megatile
    Given I have a world
      And I have one user "riley@example.com" with password "letmein"
      And I have a player in the world
      And I have an owned megatile in the world
      And there is a listing for that owned megatile
    When I retrieve the active listings for the world
    Then I should see the megatile listed for sale

  Scenario: Create a listing for a megatile
    Given I have a world
      And I have one user "riley@example.com" with password "letmein"
      And I have a player in the world
      And I own a megatile in the world
    When I list my megatile for sale
      And I retrieve the active listings for the world
    Then I should see my megatile listed for sale
