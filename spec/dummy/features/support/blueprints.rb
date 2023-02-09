when_creating_a StandardProcedure::Account, generate: { name: -> { 8.random_letters }, active_from: -> { 10.days.ago }, active_until: -> { 10.days.from_now } }
