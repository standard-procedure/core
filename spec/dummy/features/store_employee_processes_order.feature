Feature: Store employee processes order

  Scenario: Recieving a standard order
    Given an online store is configured
    When the website receives a new standard order to be processed
    Then the order should have a 24 hour deadline set against it
    And Nichola should be notified
    When Nichola logs in 
    Then she should see the newly received order
    When she places the order with the supplier
    And records the supplier information, marking the order as requiring "delivery to us"
    Then the order should marked as "awaiting delivery to us"
    And the previous deadline should be cancelled
    And a new deadline of 5 days set against the order 
    When the order arrives at the office 
    Then Nichola prepares the order for delivery and posts it
    And she records the delivery details, marking the order as "dispatched"
    And the previous deadline should be cancelled
    And a new deadline of 2 days set against the order 
    And the order should be marked as "being delivered"
    When the 2 day delivery deadline has passed
    Then the order should be marked as "completed"

  Scenario: Order is not processed in time
    Given an online store is configured
    When the website receives a new standard order to be processed
    Then the order should have a 24 hour deadline set against it
    And Nichola should be notified
    When the 24 hour deadline has passed
    Then Anna should be notified 

  Scenario: Receiving a priority order
    Given an online store is configured
    When the website receives a new priority order to be processed
    Then the order should have a 8 hour deadline set against it
    And Anna should be notified
    When Anna logs in 
    Then she should see the newly received order
    When she places the order with the supplier
    And records the supplier information, marking the order as requiring "delivery to us"
    Then the order should marked as "awaiting delivery to us"
    And the previous deadline should be cancelled
    And a new deadline of 1 day set against the order 
    When the order arrives at the office 
    Then Anna prepares the order for delivery and posts it
    And she records the delivery details, marking the order as "priority dispatch"
    And the previous deadline should be cancelled
    And a new deadline of 1 day should be set against the order 
    And the order should be marked as "being delivered"
    When the 1 day delivery deadline has passed
    Then Anna should receive a notification
    #When Anna messages the customer 
    #Then a deadline of 1 day should be set against the order 
    #When the customer replies to say that the order was received 
    #Then Anna should be notified 
    #When Anna marks the order as delivered
    #Then the order should be marked as "completed"

