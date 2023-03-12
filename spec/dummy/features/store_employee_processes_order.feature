@online_store
Feature: Store employee processes order

  Background:
    Given an account called "Online Store" loaded from "store_configuration.yml"
    And "Anna" has a "manager" account in the "employees" group
    And "Nichola" has a "staff_member" account in the "employees" group
    And "API" has an "api_user" account in the "api_users" group
    And "Registry Office 1" has a "registry_office" account in the "suppliers" group


  Scenario: Receiving a standard order
    When "API" logs in
    And creates a new "customer" called "Dave Potato" in the "customers" group
    And posts a new standard order in the customer's orders folder
    Then the "order" should have a 24 hour alert set against it
    And the "order" should have a status of "incoming_order"
    And "Nichola" should be notified
    When "Nichola" logs in
    Then she should see the newly received order
    When she places the order with the supplier
    Then the "order" should have a status of "order_placed"
    And the previous alert should be inactive
    And the "order" should have a 120 hour alert set against it
    When the order arrives at the office
    Then the "order" should have a status of "requires_dispatch"
    When "Nichola" prepares the order and posts it as "Standard" delivery
    Then the "order" should have a status of "dispatched"
    And the previous alert should be inactive
    And the "order" should have a 48 hour alert set against it
    When the 48 hour alert has passed
    Then "Nichola" should be notified
    When she completes the order
    Then the "order" should be completed

  Scenario: Order is not processed in time
    When "API" logs in
    And creates a new "customer" called "Leo Langsam" in the "customers" group
    And posts a new standard order in the customer's orders folder
    Then the "order" should have a 24 hour alert set against it
    When the 24 hour alert has passed
    Then "Nichola" should be notified

  Scenario: Receiving a priority order
    When "API" logs in
    And creates a new "customer" called "Sue Speedy" in the "customers" group
    And posts a new priority order in the customer's orders folder
    Then the "order" should have a 8 hour alert set against it
    And the "order" should have a status of "incoming_order"
    And "Anna" should be notified
    When "Anna" logs in
    Then she should see the newly received order
    When she places the order with the supplier
    Then the "order" should have a status of "order_placed"
    And the previous alert should be inactive
    And the "order" should have a 24 hour alert set against it
    When the order arrives at the office
    And "Anna" prepares the order and posts it as "Priority" delivery
    Then the "order" should have a status of "dispatched"
    And the previous alert should be inactive
    And the "order" should have a 24 hour alert set against it
    When the 24 hour alert has passed
    Then "Anna" should be notified
    When "Anna" messages the customer
    Then the "order" should have a 24 hour alert set against it
    When the customer replies to say that the order was received
    Then "Anna" should be notified
    When she completes the order
    Then the "order" should be completed
