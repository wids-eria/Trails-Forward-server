Feature: Bid on a megatile
  Megatile owners should be able to accept bids on their Megatiles

  Scenario: Accept bid on an owned megatile
    Given I have a world
      And I have one user "riley@example.com" with password "letmein"
      And I have a player in the world
      And I own a megatile in the world
      And a bid has been placed on that owned megatile
      And I can see the bids on that owned megatile
    When I accept the highest dollar bid on that megatile
    Then the bidder should own the megatile
      And my balance should increase by the amount of the bid
      And losing bids should be rejected
      And the bidder should get an email notification of the bids acceptance
      And the losing bidders should be notified
