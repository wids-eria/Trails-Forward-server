Feature: Get an authentication token
  In order to use the json api
  Clients should be able to
  retrieve an authentication token for a valid email and password

  Scenario: Get authentication token for user
    Given I have one user "riley@example.com" with password "letmein"
    When I submit the user's email and password to the users_authenticate_for_token url
    Then I should get the user's authentication token

  Scenario: Get authentication token for invalid credentials
    Given I have one user "riley@example.com" with password "letmein"
    When I submit the user's email and incorrect password to the users_authenticate_for_token url
    Then I should not get the user's authentication token
