Then("the card should have a {int} hour deadline set against it") do |int|
  @deadline = @card.deadlines.active.find_by(hours: int)
  expect(@deadline).to_not be_nil
end

When("the {int} day delivery deadline has passed") do |int|
  # do nothing
end

Then("the card should have a status of {string}") do |status|
  expect(@card.status).to eq status
end

Then("the previous deadline should be cancelled") do
  @deadline.reload
  expect(@deadline).to be_cancelled
end
