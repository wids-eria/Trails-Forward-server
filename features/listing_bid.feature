Feature: Bid on a listing
  Players should be able to bid on listings

  Background: The player is logged in to a world
    Given There have a world
      And I have a listing
      And There is another listing

  Scenario: Bid on a listing
     When I bid on the listing
     Then it should return a bid to me

  Scenario: Accept a bid on a listing
     When I accept a bid on the listing
     Then it should return an accepted bid

