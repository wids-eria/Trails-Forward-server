Feature:

  Scenario: Agent class with no specified mortality
    Given agent class:
    """
    """
    When 100 of those agents are ticked 365 times
    Then the population of those agents should be 100 with a tolerance of 10

  Scenario: Agent class just specifies mortality (no cover type modifiers)
    Given agent class:
    """
      mortality_rate 0.2
    """
    When 100 of those agents are ticked 365 times
    Then the population of those agents should be 80 with a tolerance of 5

  Scenario: Agent class just specifies survival (no cover type modifiers)
    Given agent class:
    """
      survival_rate 0.2
    """
    When 100 of those agents are ticked 365 times
    Then the population of those agents should be 20 with a tolerance of 5
