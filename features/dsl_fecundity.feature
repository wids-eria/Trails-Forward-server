Feature:

  Scenario: Agent class with no specified fecundity
    Given agent class:
    """
    """
    When 100 of those agents are ticked 365 times
    Then the population of those agents should be 100 with a tolerance of 10

  Scenario: Agent class just specifies fecundity (no cover type modifiers)
    Given agent class:
    """
      fecundity 1.62
    """
    When 100 of those agents are ticked 365 times
    Then the population of those agents should be 262 with a tolerance of 10
