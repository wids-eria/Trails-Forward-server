Feature: Generate World
  Generate a 2x2 megatile world, with 6x6 resource tiles from a 36 data row CSV file.

  Scenario: 6x6
    Given no worlds exist
    When I generate a world from "6_by_6.csv"
    Then a new world should exist
      And the new world should have 36 resource tiles
      And the new world should have 4 megatiles
